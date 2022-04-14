import { createWidget } from "lib/widget"
import * as reducers from "./reducers"
import App from "./components/application"

createWidget(null).then((widget) => {
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.url,
  })
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
