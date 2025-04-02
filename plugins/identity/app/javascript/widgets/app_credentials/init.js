import { createWidget } from "lib/widget"
import App from "./App"

createWidget({ pluginName: "app_credentials", widgetName: "app" }).then((widget) => {
  //const baseURL = widget.config.scriptParams.baseName
  const userId = widget.config.scriptParams.userId
  //console.log("baseURL", baseURL)
  widget.setPolicy()
  widget.render(App, { userId })
})
