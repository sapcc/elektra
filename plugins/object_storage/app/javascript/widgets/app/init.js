import { createWidget } from "lib/widget"
import App from "./App"

createWidget({ pluginName: "object_storage", widgetName: "app" }).then(
  (widget) => {
    widget.setPolicy()
    widget.render(App)
  }
)
