// Source: https://github.com/rw3iss/esbuild-envfile-plugin
// The original plugin has a bug and we are waiting for a fix.
// Until then, we'll use a copy with the appropriate fix.

const path = require("path")
const fs = require("fs")

module.exports = {
  name: "env",
  setup(build) {
    function _findEnvFile(dir) {
      if (!fs.existsSync(dir)) return "" // this is the fix. Instead of "false" we return an empty string here
      let filePath = `${dir}/.env`
      if (fs.existsSync(filePath)) {
        return filePath
      } else {
        return _findEnvFile(path.resolve(dir, "../"))
      }
    }

    build.onResolve({ filter: /^env$/ }, async (args) => {
      // find a .env file in current directory or any parent:
      return {
        path: _findEnvFile(args.resolveDir),
        namespace: "env-ns",
      }
    })

    build.onLoad({ filter: /.*/, namespace: "env-ns" }, async (args) => {
      // read in .env file contents and combine with regular .env:
      let data = await fs.promises.readFile(args.path, "utf8")
      const buf = Buffer.from(data)
      const config = require("dotenv").parse(buf)

      return {
        contents: JSON.stringify({ ...process.env, ...config }),
        loader: "json",
      }
    })
  },
}
