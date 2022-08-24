const sass = require("sass") // or require('node-sass');
const path = require("path")
const { sync } = require("glob")
const fs = require("fs")
const { pathToFileURL } = require("url")

const args = process.argv.slice(2)
const watch = args.indexOf("--watch") >= 0
const production =
  args.indexOf("--production") >= 0 || process.env.RAILS_ENV === "production"

const style = production ? "compressed" : "expanded"
const globalAppPath = path.resolve(__dirname, `../`)
const tempFilePath = path.join(
  globalAppPath,
  "app/assets/stylesheets/application_tmp.sass.scss"
)

try {
  fs.unlinkSync(tempFilePath)
} catch (e) {
  console.log("could not delete file " + tempFilePath)
}

fs.copyFileSync(
  path.join(globalAppPath, "app/assets/stylesheets/application.sass.scss"),
  tempFilePath
)

const pluginFiles = sync("plugins/*/**/stylesheets/*/_application.scss").map(
  (f) => {
    const nameMatch = f.match(/plugins\/([^/]+)\/.*/)
    return { name: nameMatch[1], file: f }
  }
)

pluginFiles.forEach((plugin) => {
  fs.appendFileSync(
    tempFilePath,
    "\n" +
      `/* start_${plugin.name}_plugin */` +
      "\n" +
      `.${plugin.name} { @import '${path.join(
        globalAppPath,
        plugin.file
      )}'; }` +
      "\n" +
      `/* end_${plugin.name}_plugin */` +
      "\n"
  )
})

const result = sass.compile(tempFilePath, {
  loadPaths: ["node_modules"],
  // style: "compressed",
})
let css = result.css

/* expose individual plugin css files */

// pluginFiles.forEach((plugin) => {
//   console.log(plugin)
//   const regex = new RegExp(
//     `/\\* start_${plugin.name}_plugin \\*/((.|[\r\n])*)/\\* end_${plugin.name}_plugin \\*/`
//   )
//   console.log(regex)
//   const pluginCssMatch = css.match(regex)
//   css = css.replace(regex, "")
//   if (pluginCssMatch) {
//     fs.writeFile(
//       path.resolve(
//         globalAppPath,
//         "app/assets/builds",
//         `${plugin.name}_plugin.css`
//       ),
//       sass.compileString(pluginCssMatch[1], { style }).css,
//       function (err) {
//         if (err) return console.log(err)
//       }
//     )
//   }
// })

fs.writeFile(
  path.resolve(globalAppPath, "app/assets/builds", `application.css`),
  sass.compileString(css, { style }).css,
  function (err) {
    if (err) return console.log(err)
    console.log("===DONE")
  }
)

console.log("===DONE")
