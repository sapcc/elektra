const { environment } = require('@rails/webpacker')

console.log(environment)
environment["node"] = {"fs": "empty"};
console.log(environment)

module.exports = environment
