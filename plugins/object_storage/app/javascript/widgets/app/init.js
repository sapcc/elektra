import { createWidget } from "lib/widget"
import { setApiClient, setServiceName } from "./lib/apiClient"
import { createAjaxHelper } from "lib/ajax_helper"
import App from "./App"

createWidget({ pluginName: "object_storage", widgetName: "app" }).then(
  (widget) => {
    const ajaxHelper = createAjaxHelper({
      baseURL: widget.config.scriptParams.baseName,
    })
    setApiClient(ajaxHelper)
    setServiceName(widget.config.scriptParams.service || "swift")
    widget.setPolicy()
    widget.render(App)
  }
)
