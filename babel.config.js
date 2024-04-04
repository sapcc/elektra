module.exports = {
  env: {
    test: {
      presets: ["@babel/preset-env", "@babel/preset-react"],
      plugins: [["babel-plugin-transform-import-meta", { module: "ES6" }]],
    },
  },
}
