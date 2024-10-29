// https://docs.cypress.io/guides/references/configuration
const { defineConfig } = require("cypress")

module.exports = defineConfig({
  e2e: {
    defaultCommandTimeout: 20000,
    pageLoadTimeout: 20000,
    viewportWidth: 1300,
    viewportHeight: 1100,
    videoCompression: 20,
    chromeWebSecurity: false,
    includeShadowDom: true,
    supportFile: "cypress/support/index.js", // Path to file to load before spec files load. This file is compiled and bundled. (Pass false to disable)
    specPattern: "cypress/integration/**/*.{js,jsx}", // A String or Array of glob patterns of the test files to load.
  },
})
