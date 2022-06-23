import { createWidget } from "lib/widget"
import App from "./components/Application"

createWidget(null).then((widget) => {
  widget.setPolicy()
  widget.render(App)
})
