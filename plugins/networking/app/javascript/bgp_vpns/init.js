import { createWidget } from "lib/widget"
import App from "./application"

createWidget().then((widget) => {
  widget.setPolicy()
  widget.render(App)
})
