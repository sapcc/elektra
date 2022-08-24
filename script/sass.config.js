const sass = require("sass") // or require('node-sass');
const path = require("path")
const { sync } = require("glob")
const fs = require("fs")
const { pathToFileURL } = require("url")

const args = process.argv.slice(2)
const watch = args.indexOf("--watch") >= 0
const production =
  args.indexOf("--production") >= 0 || process.env.RAILS_ENV === "production"

const globalAppPath = path.resolve(__dirname, `../`)

// sass.compile(
//   path.join(globalAppPath, "app/assets/stylesheets/application.bootstrap.scss")
// )

// console.log(
//   ":::::::::",
//   path.join(globalAppPath, "app/assets/stylesheets/application.bootstrap.scss")
// )

// sass.render(
//   {
//     file: path.join(
//       globalAppPath,
//       "app/assets/stylesheets/application.bootstrap.scss"
//     ),
//     importer: function (url, prev, done) {
//       console.log("===URL", url)
//       console.log("===PREV", prev)
//       console.log("===DONE", done)
//       // ...
//     },
//     includePaths: ["node_modules"],
//   },
//   function (err, result) {
//     console.log("===============", result)
//     console.log(err)
//     // ...
//   }
// )

const result = sass.compile(
  path.join(globalAppPath, "app/assets/stylesheets/application.sass.scss"),
  {
    // importers: [
    //   {
    //     findFileUrl(url) {
    //       if (!url.match(/\*+/)) return null
    //       const files = sync(url)
    //       let base = globalAppPath
    //       if (base && base[0] === "/") base = base.slice(1)

    //       console.log("::::", files)
    //       console.log(base)
    //       console.log(files[0])
    //       // console.log(files[0].replace(".scss", "").replace("_", ""))

    //       // return new URL(files[0])
    //       const newUrl = new URL(files[0], pathToFileURL(base))

    //       console.log("::::url", newUrl)
    //       return newUrl
    //     },
    //   },
    // ],

    // importers: [
    //   {
    //     canonicalize(url) {
    //       console.log("=================Canonicalize", url)

    //       if (url.match(/\*+/)) {
    //         let base = globalAppPath
    //         if (base && base[0] === "/") base = base.slice(1)

    //         return new URL(url, pathToFileURL(base))
    //       } else return null
    //       // return new URL(url)
    //     },
    //     load(canonicalUrl) {
    //       console.log("=================Load", canonicalUrl)
    //       const files = sync(canonicalUrl.pathname)
    //       console.log(":::::::::::::::::files", files)

    //       let content = ""
    //       files.forEach((f) => {
    //         content += "\n" + fs.readFileSync(f).toString()
    //       })
    //       // console.log(content)
    //       return {
    //         contents: content,
    //         syntax: "scss",
    //       }
    //     },
    //   },
    // ],

    importers: [
      {
        canonicalize(url) {
          if (url.match(/\*+/)) {
            // import statement contains a wildcard
            let base = globalAppPath
            if (base && base[0] === "/") base = base.slice(1)

            // return URL containing the wildcard path
            return new URL(url, pathToFileURL(base))
          } else return null
        },
        load(canonicalUrl) {
          // return a new content containing the import statement with
          // all files found by wildcard path
          const files = sync(canonicalUrl.pathname)

          // combine all files to an import statement.
          // @import 'file1', 'file2', ... 'fileX';
          let content = "@import " + files.map((f) => `'${f}'`).join(",") + ";"
          return {
            contents: content,
            syntax: "scss",
          }
        },
      },
    ],

    loadPaths: ["node_modules"],
  }
)
fs.writeFile(
  path.resolve(globalAppPath, "app/assets/builds", `application.css`),
  result.css,
  function (err) {
    if (err) return console.log(err)
    console.log("===DONE")
  }
)

// }
