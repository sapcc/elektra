import { createWidget } from "lib/widget"
import * as reducers from "./reducers"
import App from "./components/application"

// The castellum plugin will be reached via deeplinks in prometheus alerts.
// Referenced in: https://github.com/sapcc/helm-charts/blob/45d0049d7a60ddcb200892e85b7756c80be47e29/openstack/castellum/alerts/openstack/errors.alerts
createWidget(null).then((widget) => {
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.castellumApi,
    headers: { "X-Auth-Token": widget.config.scriptParams.token },
  })

  //delete params that React does not consume
  delete widget.config.scriptParams.castellumApi
  delete widget.config.scriptParams.token

  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
