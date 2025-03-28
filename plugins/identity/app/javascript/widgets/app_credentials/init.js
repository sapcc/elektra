import { createWidget } from "lib/widget"
import { createAjaxHelper } from "lib/ajax_helper"
import App from "./App"

// entrypoint for the widget
createWidget(null, { html: { class: "flex-body" } }).then((widget) => {
  const ajaxHelper = createAjaxHelper({
    baseURL: widget.config.scriptParams.baseUrl,
  })

  widget.setPolicy()
  widget.render(App)
})
