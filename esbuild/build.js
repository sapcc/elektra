#!/usr/bin/env node
const coffeeScriptPlugin = require("./coffeescript_loader_plugin")
const pathsResolverPlugin = require("./paths_resolver_plugin")
const globImportPlugin = require("./glob_import_plugin")
// const envFilePlugin = require("esbuild-envfile-plugin")
const envFilePlugin = require("./esbuild-plugin-env")
const entryPoints = require("./entrypoints")

const args = process.argv.slice(2)
const watch = args.indexOf("--watch") >= 0
const production =
  args.indexOf("--production") >= 0 || process.env.RAILS_ENV === "production"

require("esbuild")
  .build({
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
    watch,
    minify: production,
    sourcemap: !production,
    inject: ["esbuild/react-shim.js"],
  })
  .then(() => {
    if (watch) console.log("watching...")
    else console.log("done")
  })
