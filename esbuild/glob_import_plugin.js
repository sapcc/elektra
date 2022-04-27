const path = require("path")
const { sync } = require("glob")

// this plugin allows us to import globs
// e.g. import "**/*.js"
const globImportPlugin = () => ({
  name: "glob importer",
  setup(build) {
    build.onResolve({ filter: /\*+/ }, async (args) => {
      if (args.resolveDir === "") {
        return // Ignore unresolvable paths
      }

      return {
        path: args.path,
        namespace: "import-glob",
        pluginData: {
          resolveDir: args.resolveDir,
        },
      }
    })

    build.onLoad({ filter: /.*/, namespace: "import-glob" }, async (args) => {
      const files = sync(path.resolve(args.pluginData.resolveDir, args.path))

      let importerCode = `
        ${files
          .map((module, index) => `import * as module${index} from '${module}'`)
          .join(";")}
        const modules = [${files
          .map((module, index) => `module${index}`)
          .join(",")}];
        export default modules;
        export const filenames = [${files
          .map((module, index) => `'${module}'`)
          .join(",")}]
      `

      return { contents: importerCode, resolveDir: args.pluginData.resolveDir }
    })
  },
})

module.exports = globImportPlugin
