module.exports = {
  automock: false,
  setupFiles: ["./setupJestMock.js"],
  verbose: true,
  testRegex: "\\.test\\.jsx?$",
  modulePathIgnorePatterns: ["vendor"],
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
  // see also in config/esbuild/build.js
  moduleNameMapper: {
    ajax_helper: "<rootDir>/app/javascript/lib/ajax_helper.js",
    testHelper: "<rootDir>/app/javascript/test/support/testHelper.js",
    "^lib/(.*)$": "<rootDir>/app/javascript/lib/$1",
    "^core/(.*)$": "<rootDir>/app/javascript/core/$1",
    "^plugins/(.*)$": "<rootDir>/plugins/$1",
    "^config/(.*)$": "<rootDir>/config/$1",
  },
  testEnvironment: "jsdom",
  // include juno-ui-components into the transform process
  transformIgnorePatterns: ["node_modules/(?!juno-ui-components)"],
}
