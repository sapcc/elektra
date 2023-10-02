import { createWidget } from "lib/widget"
import { setApiClient } from "./lib/apiClient"
import { createAjaxHelper } from "lib/ajax_helper"
import App from "./App"

createWidget({ pluginName: "object_storage_ng", widgetName: "app" }).then(
  (widget) => {
    const ajaxHelper = createAjaxHelper({
      baseURL: widget.config.scriptParams.baseName,
    })
    setApiClient(ajaxHelper)
    widget.setPolicy()
    widget.render(App)
  }
)
