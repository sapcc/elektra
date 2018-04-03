// config/webpack/custom.js
const path = require('path');
const { sync } = require('glob')

let customConfig = {
  entry: {},
  resolve: {
    modules: sync('plugins/*/app/javascript')
  },
  node: {
    __filename: true,
    __dirname: true
  }
}

const widget_paths = sync('plugins/*/app/javascript/*/init.js')
for(let index in widget_paths) {
  let widget_path = widget_paths[index]
  const name_regex = /.*plugins\/([^\/]+)\/app\/javascript\/([^\.]+)\/init.js/
  const name_tokens = widget_path.match(name_regex);
  const widget_name = `${name_tokens[1]}_${name_tokens[2]}`

  let widget_absolute_path = path.resolve(__dirname, `../../${widget_path}`)
  customConfig.entry[widget_name] = widget_absolute_path
}

function extendConfig(orgConfig) {
  if (orgConfig.toWebpackConfig){
    orgConfig = orgConfig.toWebpackConfig()
  }

  orgConfig.resolve.modules = orgConfig.resolve.modules.concat(customConfig.resolve.modules)
  Object.assign(orgConfig.entry, customConfig.entry)
  orgConfig.node = orgConfig.node || {}
  Object.assign(orgConfig.node, customConfig.node)
  // console.log(orgConfig)
  return orgConfig
}

module.exports = extendConfig
