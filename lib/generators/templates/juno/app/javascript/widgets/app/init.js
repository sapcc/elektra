import { createWidget } from "lib/widget"
import App from "./components/Application"

createWidget({ pluginName: "%{PLUGIN_NAME}", widgetName: "app" }).then(
  (widget) => {
    widget.setPolicy()
    widget.render(App)
  }
)
