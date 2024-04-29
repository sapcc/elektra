import { createWidget } from "lib/widget"
import { setApiClient } from "./lib/apiClient"
import { createAjaxHelper } from "lib/ajax_helper"
import App2 from "./App2"

// entrypoint for the widget
createWidget(null, { html: { class: "flex-body" } }).then((widget) => {
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.url,
  })

  const ajaxHelper = createAjaxHelper({
    baseURL: widget.config.scriptParams.baseName,
  })
  setApiClient(ajaxHelper)

  widget.setPolicy()
  widget.render(App2)
})
