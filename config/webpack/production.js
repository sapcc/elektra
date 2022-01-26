process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const extendConfig = require('./custom')

module.exports = extendConfig(environment)
