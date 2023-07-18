import { createWidget } from "lib/widget"
import * as reducers from "./reducers"
import App from "./containers/app"

createWidget().then(async (widget) => {
  // get token function from elektra
  const getTokenFunc = globalThis[widget.config.scriptParams.getTokenFunc]
  // wait for token
  const token = await getTokenFunc()

  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.eventsApi,
    headers: { "X-Auth-Token": token.authToken },
  })
  // cleanup
  delete widget.config.scriptParams.eventsApi
  delete widget.config.scriptParams.token
  delete widget.config.scriptParams.getTokenFunc

  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
