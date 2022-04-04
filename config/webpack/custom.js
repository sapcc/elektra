// config/webpack/custom.js
const path = require("path")
const { sync } = require("glob")

const yaml = require("js-yaml")
const fs = require("fs")

// Because the settings in webpacker.yml are not transferred to webpack.config,
// we do this manually. We load the yaml file and read the values for devServer, if any.
let webpackerConfig
try {
  webpackerConfig = yaml.load(
    fs.readFileSync(path.resolve(__dirname, `../webpacker.yml`), "utf8")
  )
} catch (e) {}

let customConfig = {
  entry: {},
  resolve: {
    modules: sync("plugins/*/app/javascript"),
  },
  node: {
    __filename: true,
    __dirname: true,
  },
}

const widget_paths = sync("plugins/*/app/javascript/*/init.js")
for (let index in widget_paths) {
  let widget_path = widget_paths[index]
  const name_regex = /.*plugins\/([^\/]+)\/app\/javascript\/([^\.]+)\/init.js/
  const name_tokens = widget_path.match(name_regex)
  const widget_name = `${name_tokens[1]}_${name_tokens[2]}`

  let widget_absolute_path = path.resolve(__dirname, `../../${widget_path}`)
  customConfig.entry[widget_name] = widget_absolute_path
}

function extendConfig(orgConfig) {
  if (orgConfig.toWebpackConfig) {
    orgConfig = orgConfig.toWebpackConfig()
    // https://github.com/gloriaJun/til/issues/3
    orgConfig.output.filename = "js/[name]-[hash].js"
  }

  orgConfig.resolve.modules = orgConfig.resolve.modules.concat(
    customConfig.resolve.modules
  )
  Object.assign(orgConfig.entry, customConfig.entry)
  orgConfig.node = orgConfig.node || {}
  Object.assign(orgConfig.node, customConfig.node)

  // Apply setting for devServer from webpacker.yaml if defined.
  if (
    webpackerConfig &&
    webpackerConfig.development &&
    webpackerConfig.development.dev_server
  ) {
    const devServer = webpackerConfig.development.dev_server
    orgConfig.devServer = orgConfig.devServer || {}
    if (devServer.host) orgConfig.devServer.host = devServer.host
    if (devServer.port) orgConfig.devServer.port = devServer.port
    if (devServer.public) orgConfig.devServer.public = devServer.public
  }

  return orgConfig
}

module.exports = extendConfig
