// `@babel/polyfill` is deprecated
// https://github.com/zloirock/core-js/blob/master/docs/2019-03-19-core-js-3-babel-and-a-look-into-the-future.md#babel
import "core-js/stable";
import "regenerator-runtime/runtime";

function importAll (r) {
  r.keys().forEach(r);
}

// import all global js from plugins.
// Normally, a pack is not loaded until explicitly requested. However,
// there are situations where packs should be globally available. In this case,
// each such plug-in should define a special file called global.js.
// Everything within global.js is executed on every page load.
importAll(require.context("../../../plugins", true, /.\global.js/));
