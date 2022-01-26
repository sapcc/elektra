process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const extendConfig = require('./custom')

module.exports = extendConfig(environment)

