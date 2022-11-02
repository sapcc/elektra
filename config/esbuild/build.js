#!/usr/bin/env node
const coffeeScriptPlugin = require("./coffeescript_loader_plugin")
const pathsResolverPlugin = require("./paths_resolver_plugin")
const globImportPlugin = require("./glob_import_plugin")
// const postCssPlugin = require("esbuild-style-plugin")
const postCssPlugin = require("@deanc/esbuild-plugin-postcss")

// const envFilePlugin = require("esbuild-envfile-plugin")
const envFilePlugin = require("./esbuild-plugin-env")
const entryPoints = require("./entrypoints")

const esbuild = require("esbuild")
const path = require("path")
const args = process.argv.slice(2)
const watch = args.indexOf("--watch") >= 0
const production =
  args.indexOf("--production") >= 0 || process.env.RAILS_ENV === "production"
const log = console.log.bind(console)

const config = {
  entryPoints: entryPoints(
    [
      // all "*" are replaced with the path tokens and joined by "_"
      { path: "app/javascript/*.{js,jsx,coffee}" }, // all js and jsx files in app/javascript folder
      {
        path: "plugins/*/app/javascript/plugin.{js,jsx,coffee}",
        suffix: "plugin",
      }, // all plugin.js files in all plugins
      {
        path: "plugins/*/app/javascript/widgets/*/init.{js,jsx,coffee}",
        suffix: "widget",
      },
    ],
    { log: true }
  ),
  bundle: true,
  platform: "browser",
  // format: "esm",
  // splitting: true,
  outdir: "app/assets/builds",
  plugins: [
    envFilePlugin,
    pathsResolverPlugin({
      // see also in jest.config.js
      lib: "app/javascript/lib",
      core: "app/javascript/core",
      plugins: "plugins",
      config: "config",
    }),
    globImportPlugin(),
    coffeeScriptPlugin(),
    postCssPlugin({
      plugins: [require("tailwindcss"), require("autoprefixer")],
    }),
  ],
  //loader: { ".js": "jsx" },
  target: ["es6", "chrome58", "firefox57", "safari11", "edge18"],
  // watch: watch && {
  //   onRebuild(error, result) {
  //     if (!error) {
  //       console.log("\033[2J")
  //       console.log(
  //         "\x1b[32m%s\x1b[0m",
  //         "Rebuild completed successfully with no errors! Don't worry Be Happy :)"
  //       ) //cyan
  //       console.log("watching...")
  //     }
  //   },
  // },
  minify: production,
  sourcemap: !production,
  inject: [path.resolve(__dirname, "./react-shim.js")],
  // map global this to window
  define: { this: "window" },
  allowOverwrite: true,
  loader: {
    // built-in loaders: js, jsx, ts, tsx, css, json, text, base64, dataurl, file, binary
    ".ttf": "file",
    ".otf": "file",
    ".svg": "file",
    ".eot": "file",
    ".woff": "file",
    ".woff2": "file",
    ".inline.css": "text",
  },
}

const grey = "\x1b[30m%s\x1b[0m"
const red = "\x1b[31m%s\x1b[0m"
const green = "\x1b[32m%s\x1b[0m"
const yellow = "\x1b[33m%s\x1b[0m"
const blue = "\x1b[34m%s\x1b[0m"

function compile(options = {}) {
  if (options.clear) console.clear()
  if (options.change) {
    log(yellow, "◻️ Change detected -> compile")
  } else {
    log(yellow, "◻️ First compile...")
  }

  return esbuild
    .build(config)
    .then(() => {
      log(
        green,
        "◻️ Compile completed successfully with no errors! Don't worry Be Happy 🙂"
      )
    })
    .catch((error) => {
      log(red, "Compile completed with error 😐")
      console.error(error)
      if (process.env.RAILS_ENV === "production") {
        // exit if we have an error on production build
        process.exit(1)
      }
    })
}

if (watch) {
  compile().then(() => {
    //******************************************** */
    const chokidar = require("chokidar")
    // Initialize watcher.
    const watcher = chokidar.watch(
      Object.values([
        "app/assets/stylesheets/**/*.css",
        "app/javascript/**/*.{js,jsx,coffee,css}",
        "plugins/*/app/javascript/**/*.{js,jsx,coffee,css}",
      ]),
      {
        // eslint-disable-next-line no-useless-escape
        ignored: /(^|[\/\\])\../, // ignore dotfiles
        persistent: true,
        ignoreInitial: true,
      }
    )

    // Add event listeners.
    watcher
      .on("ready", () => {
        log(blue, "◻️ Watching for changes 👀")
      })
      .on("add", (path) => {
        watcher.add(path)
        compile({ clear: true, change: true }).then(() => {
          log(grey, " ◻️ Reason: file has been added 🚀")
          log(grey, ` ◻️ File: ${path}`)
        })
      })
      .on("change", (path) => {
        compile({ clear: true, change: true }).then(() => {
          log(grey, " ◻️ Reason: file has been changed ⚙️")
          log(grey, ` ◻️ File: ${path}`)
        })
      })
      .on("unlink", (path) => {
        compile({ clear: true, change: true }).then(() => {
          log(grey, " ◻️ Reason: file has been removed 💀")
          log(grey, ` ◻️ File: ${path}`)
        })
      })
      .on("addDir", (path) => {
        watch.add(`${path}*.{js,jsx,coffee}`)
        compile({ clear: true, change: true })
        log(grey, " ◻️ Reason: directory has been added 🚀")
        log(grey, ` ◻️ Directory: ${path}`)
      })
      .on("unlinkDir", (path) => {
        compile({ clear: true, change: true })
        log(grey, " ◻️ Reason: directory has been removed 💀")
        log(grey, ` ◻️ Directory: ${path}`)
      })
      .on("error", (error) => log(red, `Watcher error: ${error} 👎`))
  })
} else {
  compile()
}
