import { createWidget } from "lib/widget"
import App from "./App"

// entrypoint for the widget
createWidget(null, { html: { class: "flex-body" } }).then((widget) => {
  widget.render(App)
})
