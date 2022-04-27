import { createWidget } from "lib/widget"
import * as reducers from "./reducers"
import App from "./containers/app"

createWidget().then((widget) => {
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.eventsApi,
    headers: { "X-Auth-Token": widget.config.scriptParams.token },
  })
  delete widget.config.scriptParams.eventsApi
  delete widget.config.scriptParams.token
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
