import { createWidget } from "lib/widget"
import App from "./application"

createWidget({ pluginName: "object_storage_ng", widgetName: "app" }).then(
  (widget) => {
    widget.setPolicy()
    widget.render(App)
  }
)
