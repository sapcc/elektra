import { createWidget } from "lib/widget"
import App from "./App"

createWidget({ pluginName: "", widgetName: "landing_page" }).then((widget) => {
  widget.render(App)
})
