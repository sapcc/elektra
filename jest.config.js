module.exports = {
  verbose: true,
  testRegex: "\\.test\\.js$",
  transform: {
    "^.+\\.jsx?$": [
      "esbuild-jest",
      {
        jsx: "preserve",
        loader: { ".js": "jsx" },
        sourcemap: true,
      },
    ],
  },
  moduleNameMapper: {
    ajax_helper: "<rootDir>/app/javascript/lib/ajax_helper.js",
    testHelper: "<rootDir>/app/javascript/test/support/testHelper.js",
  },
  setupFilesAfterEnv: ["<rootDir>/app/javascript/test/support/setupEnzyme.js"],
}
