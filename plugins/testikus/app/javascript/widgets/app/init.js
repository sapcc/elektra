import { createWidget } from "lib/widget"
import App from "./components/Application"

createWidget({ pluginName: "testikus", widgetName: "app" }).then(
  (widget) => {
    widget.setPolicy()
    widget.render(App)
  }
)
