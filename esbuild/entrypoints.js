const { sync } = require("glob")

// helper function to add glob entry points
function resolveFiles(pathPattern, { suffix }) {
  const result = {}
  const regex = new RegExp(
    pathPattern.replace(/\*/g, "([^/|.]+)").replace(/\.\{.*$/, "")
  )

  // console.log(regex)
  const files = sync(pathPattern).sort()
  for (let path of files) {
    const tokens = path.match(regex)
    let name = tokens.length > 1 ? tokens.slice(1).join("_") : path
    if (suffix) name += `_${suffix}`
    result[name] = path
  }
  return result
}

module.exports = (entries, options = {}) => {
  let entryPoints = {}
  for (let entry of entries) {
    const newEntryPoints = resolveFiles(entry.path, { suffix: entry.suffix })
    entryPoints = { ...entryPoints, ...newEntryPoints }
  }
  if (options.log) console.log(entryPoints)
  return entryPoints
}
