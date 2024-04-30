import { createWidget } from "lib/widget"
import {
  serviceEndpoint,
  setApiClient,
  setServiceName,
  setServiceEndpoint,
} from "./lib/apiClient"
import { createAjaxHelper } from "lib/ajax_helper"
import App from "./App"

createWidget({ pluginName: "object_storage", widgetName: "app" }).then(
  (widget) => {
    const ajaxHelper = createAjaxHelper({
      baseURL: widget.config.scriptParams.baseName,
    })
    setApiClient(ajaxHelper)
    setServiceName(widget.config.scriptParams.serviceName)
    setServiceEndpoint(widget.config.scriptParams.serviceEndpoint)
    widget.setPolicy()
    widget.render(App)

    console.log("::::::::::", serviceEndpoint)
  }
)
