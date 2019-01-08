const environment = require('./environment')
const extendConfig = require('./custom')

module.exports = extendConfig(environment)
