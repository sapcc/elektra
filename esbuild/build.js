#!/usr/bin/env node

const coffeeScriptPlugin = require("./coffeescript_loader_plugin")
const pathsResolverPlugin = require("./paths_resolver_plugin")
const globImportPlugin = require("./glob_import_plugin")
const envFilePlugin = require("esbuild-envfile-plugin")
const entryPoints = require("./entrypoints")

const args = process.argv.slice(2)
const watch = args.indexOf("--watch") >= 0

require("esbuild")
  .build({
    entryPoints: entryPoints(
      [
        "app/javascript/*.js", // all js files in app/javascript folder
        "app/javascript/*.coffee", // all coffeescript files in app/javascript folder
        "plugins/*/app/javascript/*/init.js", // all initi.js files in all plugins
      ],
      { log: true }
    ),
    bundle: true,
    platform: "browser",
    outdir: "app/assets/builds",
    plugins: [
      envFilePlugin,
      pathsResolverPlugin({
        lib: "app/javascript/lib",
        core: "app/javascript/core",
        config: "config",
      }),
      globImportPlugin(),
      coffeeScriptPlugin(),
    ],
    loader: { ".js": "jsx" },
    target: ["es6"],
    watch,
  })
  .then((result) => {
    if (watch) console.log("watching...")
    else console.log("done")
  })
