import { createWidget } from "lib/widget"
import TagsApp from "./App"

// magic happens here to create for elektra the react app
createWidget(null).then((widget) => {
  widget.setPolicy()
  widget.render(TagsApp)
})
