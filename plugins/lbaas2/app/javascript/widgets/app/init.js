import { createWidget } from "lib/widget"
import App from "./App"

createWidget()
  .then((widget) => {
    widget.configureAjaxHelper()
    widget.setPolicy()
    widget.render(App)
  })
  .catch((e) => console.error(e))
