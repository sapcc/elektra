// We have to load jQuery in an extra file, otherwise other modules that build
// on jquery cannot access jquery. This is because after loading jQuery we need
// to set window.$ and window.jQuery before loading other modules.
// Since Javascript automatically moves all imports to the top, the $ is set later.
//
// This problem is avoided by loading jQuery in a separate file.

import jquery from "jquery"
window.$ = window.jQuery = jquery
