import { createWidget } from "lib/widget"
import * as reducers from "./reducers"
import App from "./containers/app"

createWidget()
  .then((widget) => {
    widget.configureAjaxHelper({
      baseURL: widget.config.scriptParams.url,
    })
    widget.setPolicy()
    widget.createStore(reducers)
    widget.render(App)
  })
  .catch((e) => console.error(e))
