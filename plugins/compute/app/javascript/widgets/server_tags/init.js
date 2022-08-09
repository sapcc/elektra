import { createWidget } from "lib/widget"
import TagsApp from "./App"

// magic happens here to create for elektra the react app
createWidget({ pluginName: "compute", widgetName: "server_tags" }).then(
  (widget) => {
    widget.setPolicy()
    widget.render(TagsApp)
  }
)
