#!/usr/bin/env node
const coffeeScriptPlugin = require("./coffeescript_loader_plugin")
const pathsResolverPlugin = require("./paths_resolver_plugin")
const globImportPlugin = require("./glob_import_plugin")
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
      lib: "app/javascript/lib",
      core: "app/javascript/core",
      plugins: "plugins",
      config: "config",
    }),
    globImportPlugin(),
    coffeeScriptPlugin(),
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
  loader: { ".css": "text" },
}

// function compile(options = {}) {
//   if (options.clear) console.clear() // log("\033[2J")
//   log("Compiling...")
//   return esbuild.build(config).then(() => {
//     log(
//       "\x1b[32m%s\x1b[0m",
//       "Rebuild completed successfully with no errors! Don't worry Be Happy :)"
//     ) //cyan
//   })
// }

function compile(options = {}) {
  if (options.clear) console.clear() // log("\033[2J")
  log("Compiling...")

  // return esbuild
  //   .serve(
  //     {
  //       servedir: "www",
  //       port: 8080,
  //     },
  //     { ...config, outdir: "www/js" }
  //   )
  //   .then((server) => {
  //     log("Stop", server)
  //     // Call "stop" on the web server to stop serving
  //     //server.stop()
  //   })

  return esbuild.build(config).then(() => {
    log(
      "\x1b[32m%s\x1b[0m",
      "Rebuild completed successfully with no errors! Don't worry Be Happy :)"
    ) //cyan
  })
}

if (watch) {
  compile().then(() => {
    //******************************************** */
    const chokidar = require("chokidar")
    // Initialize watcher.
    const watcher = chokidar.watch(Object.values(config.entryPoints), {
      ignored: /(^|[\/\\])\../, // ignore dotfiles
      persistent: true,
      ignoreInitial: true,
    })

    // Add event listeners.
    watcher
      .on("ready", () => log("Watching..."))
      .on("add", (path) => {
        log(`File ${path} has been added`)
        watcher.add(path)
        compile({ clear: true })
      })
      .on("change", (path) => {
        log(`File ${path} has been changed`)
        compile({ clear: true })
      })
      .on("unlink", (path) => {
        log(`File ${path} has been removed`)
        compile({ clear: true })
      })
      .on("addDir", (path) => {
        log(`Directory ${path} has been added`)
        watch.add(`${path}*.{js,jsx,coffee}`)
        compile({ clear: true })
      })
      .on("unlinkDir", (path) => {
        log(`Directory ${path} has been removed`)
        compile({ clear: true })
      })
      .on("error", (error) => log(`Watcher error: ${error}`))
  })
} else {
  compile()
}
