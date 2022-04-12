const { sync } = require("glob")

// helper function to add glob entry points
function resolveFiles(pathPattern) {
  const result = {}
  const regex = new RegExp(
    pathPattern.replace(/\*/g, "([^/|.]+)").replace(/\.\{.*$/, "")
  )

  // console.log(regex)
  const files = sync(pathPattern).sort()
  for (let path of files) {
    const tokens = path.match(regex)
    const name = tokens.length > 1 ? tokens.slice(1).join("_") : path
    result[name] = path
  }
  return result
}

module.exports = (globPatterns, options = {}) => {
  let entryPoints = {}
  for (let pattern of globPatterns) {
    const newEntryPoints = resolveFiles(pattern)
    entryPoints = { ...entryPoints, ...newEntryPoints }
  }
  if (options.log) console.log(entryPoints)
  return entryPoints
}
