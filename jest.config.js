const {defaults} = require("jest-config");
module.exports = {
  "verbose": true,
  "testRegex": "\\.test\\.js$",
  "transform": {
    "^.+\\.js$": "babel-jest"
  },
  "moduleNameMapper": {
    "ajax_helper": "<rootDir>/app/javascript/ajax_helper.js"
  }
};
