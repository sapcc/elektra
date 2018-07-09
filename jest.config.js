const {defaults} = require("jest-config");
module.exports = {
  "verbose": true,
  "testRegex": "\\.test\\.js$",
  "transform": {
    "^.+\\.jsx$": "babel-jest",
    "^.+\\.js$": "babel-jest"
  },
  "moduleNameMapper": {
    "ajax_helper": "<rootDir>/app/javascript/ajax_helper.js"
  },
  "setupTestFrameworkScriptFile": "<rootDir>/plugins/lookup/app/javascript/reverse_app/test/setupEnzyme.js"
};
