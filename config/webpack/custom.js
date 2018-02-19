// config/webpack/custom.js
const path = require('path');
const { sync } = require('glob')

let customConfig = {
  entry: {},
  resolve: {
    modules: sync('plugins/*/app/javascript')
  }
}

const widget_paths = sync('plugins/*/app/javascript/packs/widget.js')
for(let index in widget_paths) {
  let widget_path = widget_paths[index]
  let widget_name = widget_path.split('/')[1]
  let widget_absolute_path = path.resolve(__dirname, `../../${widget_path}`)
  customConfig.entry[widget_name] = widget_absolute_path
}

function extendConfig(orgConfig) {
  if (orgConfig.toWebpackConfig){
    orgConfig = orgConfig.toWebpackConfig()
  }

  //orgConfig.resolve.modules = orgConfig.resolve.modules.concat(customConfig.resolve.modules)
  Object.assign(orgConfig.entry, customConfig.entry)
  // console.log(orgConfig)
  return orgConfig
}

module.exports = extendConfig
