const sass = require("sass") // or require('node-sass');
const path = require("path")
const { sync } = require("glob")
const fs = require("fs")

const globalAppPath = path.resolve(__dirname, `./`)

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
  path.join(globalAppPath, "app/assets/stylesheets/application.bootstrap.scss"),
  {
    importers: [
      {
        findFileUrl(url) {
          if (!url.match(/\*+/)) return null
          const files = sync(url)

          // return new URL(files[0])
          return new URL(
            globalAppPath,
            files[0].replace(".scss", "").replace("_", "")
          )
        },
      },
    ],

    // importers: [
    //   {
    //     canonicalize(url, b, c, d) {
    //       console.log("=================Canonicalize", url)
    //       console.log("=================Canonicalize", b, c, d)

    //       if (url.match(/\*+/)) {
    //         console.log(":::::::::::::::::::::::::::::::::::::::")
    //         //return new URL(url)
    //         return url
    //       }
    //       // return new URL(url)
    //     },
    //     load(canonicalUrl) {
    //       console.log("=================Load", canonicalUrl)
    //       //if (!url.match(/\*+/)) return new URL(url)

    //       //const files = sync(url)
    //     },
    //   },
    // ],
    loadPaths: ["node_modules"],
  }
)

//console.log("===============", result)

// console.log(
//   path.resolve(
//     globalAppPath,
//     "plugins/*/app/assets/stylesheets/**/plugin*.scss"
//   )
// )

// const files = sync(
//   path.resolve(
//     globalAppPath,
//     "plugins/*/app/assets/stylesheets/**/plugin*.scss"
//   )
// )

// for (let file of files) {
//   const match = file.match(/plugins\/([^/]+)/)
//   const name = match && match[1]
//   if (!name) continue
//   console.log(name)
//   console.log("===FILE", file)
//   const result = sass.compile(file, {
//     loadPaths: [
//       path.join(__dirname, "node_modules"), // npm
//     ],
//   })

//   fs.writeFile(
//     path.resolve(globalAppPath, "app/assets/builds", `${name}_plugin.css`),
//     result.css,
//     function (err) {
//       if (err) return console.log(err)
//       console.log("===DONE")
//     }
//   )

//   /* ... */
//   console.log("=====================================")
//   console.log(result)
// }
