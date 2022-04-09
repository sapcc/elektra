import { createWidget } from "lib/widget"
import * as reducers from "./reducers"
import App from "./containers/application"

createWidget().then((widget) => {
  widget.configureAjaxHelper({
    headers: { "X-Requested-With": "XMLHttpRequest" },
  })
  widget.createStore(reducers)
  widget.setPolicy()
  widget.render(App)
})
