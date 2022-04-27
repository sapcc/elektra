process.env.NODE_ENV = process.env.NODE_ENV || "development"

const path = require("path")
const yaml = require("js-yaml")
const fs = require("fs")

const environment = require("./environment")
const extendConfig = require("./custom")

// Because the settings in webpacker.yml are not transferred to webpack.config,
// we do this manually. We load the yaml file and read the values for devServer, if any.
try {
  const webpackerConfig = yaml.load(
    fs.readFileSync(path.resolve(__dirname, `../webpacker.yml`), "utf8")
  )

  environment.config.devServer = {
    ...environment.config.devServer,
    port: webpackerConfig.development.dev_server.port,
  }
} catch (e) {
  console.error(e)
}

module.exports = extendConfig(environment)
