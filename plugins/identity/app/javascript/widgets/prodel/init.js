import { createWidget } from "lib/widget"
import { setApiClient } from "./lib/apiClient"
import { createAjaxHelper } from "lib/ajax_helper"
import App from "./App"

// entrypoint for the widget
createWidget(null, { html: { class: "flex-body" } }).then((widget) => {
  const ajaxHelper = createAjaxHelper({
    baseURL: widget.config.scriptParams.baseUrl,
  })
  setApiClient(ajaxHelper)

  widget.setPolicy()
  widget.render(App)
})
