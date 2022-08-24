// Source: https://github.com/rw3iss/esbuild-envfile-plugin
// The original plugin has a bug and we are waiting for a fix.
// Until then, we'll use a copy with the appropriate fix.

const path = require("path")
const fs = require("fs")

module.exports = {
  name: "env",
  setup(build) {
    function _findEnvFile(dir) {
      if (!fs.existsSync(dir) || dir === "/") return false
      let filePath = `${dir}/.env`
      if (fs.existsSync(filePath)) {
        return filePath
      } else {
        return _findEnvFile(path.resolve(dir, ".."))
      }
    }

    // Intercept import paths called "env" so esbuild doesn't attempt
    // to map them to a file system location. Tag them with the "env-ns"
    // namespace to reserve them for this plugin.
    build.onResolve({ filter: /^env$/ }, (args) => ({
      path: args.path,
      namespace: "env-ns",
      pluginData: { currentDir: args.resolveDir },
    }))

    // Load paths tagged with the "env-ns" namespace and behave as if
    // they point to a JSON file containing the environment variables.
    build.onLoad({ filter: /.*/, namespace: "env-ns" }, async (args) => {
      // try to find the env file
      let envPath = _findEnvFile(args.pluginData.currentDir)
      let contents = JSON.stringify(process.env)

      // if env file exists then add it to contents
      if (envPath) {
        let data = await fs.promises.readFile(envPath, "utf8")
        const buf = Buffer.from(data)
        const config = require("dotenv").parse(buf)
        contents = JSON.stringify({ ...process.env, ...config })
      }

      return {
        contents,
        loader: "json",
      }
    })
  },
}
