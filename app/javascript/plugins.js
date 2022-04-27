// Normally, plugin's javascripts is not loaded until explicitly requested. However,
// there are situations where plugin functionality should be globally available. In this case,
// each such plugin should define a special file called global.js.
// Everything within global.js is executed on every page load.
import "../../plugins/**/app/javascript/**/global.{js,jsx}"
