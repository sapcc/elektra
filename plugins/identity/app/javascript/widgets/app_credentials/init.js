import { createWidget } from "lib/widget"
import App from "./App"
import { createApiClient } from "./apiClient"

createWidget({ pluginName: "app_credentials", widgetName: "app" }).then((widget) => {
  //console.log(widget.config.scriptParams)
  const projectId = widget.config.scriptParams.projectId
  const domainId = widget.config.scriptParams.domainId
  //console.log("projectId", projectId)
  // build the baseURL for the apiClient
  // that is needed to use the /os-api/ proxy that is provided by elektra
  const baseURL = `/${domainId}/${projectId}/identity`
  //console.log("baseURL", baseURL)
  createApiClient(baseURL)
  const userId = widget.config.scriptParams.userId

  widget.setPolicy()
  widget.render(App, { userId })
})
