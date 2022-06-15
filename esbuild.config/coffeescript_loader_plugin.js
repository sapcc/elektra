const fs = require("fs")
const path = require("path")
const coffeescript = require("coffeescript")

const omit = (obj, keys) =>
  Object.keys(obj)
    .filter((key) => !keys.includes(key))
    .reduce((res, key) => Object.assign(res, { [key]: obj[key] }), {})

const compileCoffee = (code, options) => coffeescript.compile(code, options)

const convertMessage = ({ message, location, code, filename }) => {
  location = {
    file: filename,
    line: location.first_line,
    column: location.first_column,
    length: location.first_line - location.last_column,
    lineText: code,
  }
  return { text: message, location }
}

const coffeeScriptPlugin = (options = {}) => ({
  name: "coffeescript",
  setup(build) {
    build.onLoad({ filter: /.\.(coffee|litcoffee)$/ }, async (args) => {
      const source = await fs.readFileSync(args.path, "utf8")
      const filename = path.relative(process.cwd(), args.path)
      const opt = omit(options, ["sourceMap"])

      try {
        const contents = compileCoffee(source, { filename, ...opt })
        return {
          contents,
        }
      } catch (e) {
        return {
          errors: [convertMessage(e)],
        }
      }
    })
  },
})

module.exports = coffeeScriptPlugin
