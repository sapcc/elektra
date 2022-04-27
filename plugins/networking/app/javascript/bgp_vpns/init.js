import { createWidget } from "widget"
import App from "./application"

createWidget().then((widget) => {
  widget.setPolicy()
  widget.render(App)
})
