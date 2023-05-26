import { createWidget } from "lib/widget"
import * as reducers from "./reducers"
import App from "./components/application"

createWidget(null, { html: { } }).then((widget) => {
  widget.configureAjaxHelper()
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
