import { createWidget } from "lib/widget"
import App from "./App"

createWidget(null, { html: { class: "flex-body" } }).then((widget) => {
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.url,
  })
  widget.setPolicy()
  widget.render(App)
})
