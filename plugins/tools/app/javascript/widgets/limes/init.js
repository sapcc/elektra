import { createWidget } from "lib/widget"
import * as reducers from "./reducers"
import App from "./components/application"

createWidget(null).then((widget) => {
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.limesApi,
    headers: { "X-Auth-Token": widget.config.scriptParams.token },
  })

  //delete params that React does not consume
  delete widget.config.scriptParams.limesApi
  delete widget.config.scriptParams.token

  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
