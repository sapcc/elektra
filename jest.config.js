const {defaults} = require("jest-config");
module.exports = {
  "verbose": true,
  "testRegex": "\\.test\\.js$",
  "transform": {
    "^.+\\.jsx$": "babel-jest",
    "^.+\\.js$": "babel-jest"
  },
  "moduleNameMapper": {
    "ajax_helper": "<rootDir>/app/javascript/ajax_helper.js",
    "testHelper": "<rootDir>/app/javascript/test/support/testHelper.js"
  },
  "setupTestFrameworkScriptFile": "<rootDir>/app/javascript/test/support/setupEnzyme.js"
};
