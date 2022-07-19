import { createWidget } from "lib/widget"
import TagsApp from "./App"

createWidget(null).then((widget) => {
  widget.setPolicy()
  widget.render(TagsApp)
})
