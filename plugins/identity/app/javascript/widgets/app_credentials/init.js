import { createWidget } from "lib/widget"
import App from "./App"
import { createApiClient } from "./apiClient"

createWidget({ pluginName: "app_credentials", widgetName: "app" }).then((widget) => {
  //console.log(widget.config.scriptParams)
  const projectName = widget.config.scriptParams.projectName
  const projectId = widget.config.scriptParams.projectId

  const domainName = widget.config.scriptParams.domainName
  //console.log("projectId", projectName)
  //console.log("domainId", domainName)
  // build the baseURL for the apiClient
  // that is needed to use the /os-api/ proxy that is provided by elektra
  const baseURL = `/${domainName}/${projectName}/identity`
  //console.log("baseURL", baseURL)
  createApiClient(baseURL)
  const userId = widget.config.scriptParams.userId

  widget.setPolicy()
  widget.render(App, { userId, projectId })
})
