import React from "react"
import ReactDOM from "react-dom"
import App from "./App"
import {
  getWidgetName,
  getContainerFromCurrentScript,
  createConfig,
} from "lib/widget"
import { configureAjaxHelper } from "lib/ajax_helper"
import { setPolicy } from "lib/policy"

const createNewConfig = (widgetName, scriptParams) => {
  // if document is already loaded then resolve Promise immediately
  // with a new widget object
  if (document.readyState === "complete")
    return Promise.resolve(
      createConfig(widgetName, scriptTagContainer.scriptParams)
    )
  // // document is not loaded yet -> create a new Promise and resolve it as soon
  // // as document is loaded.
  return new Promise((resolve, reject) => {
    document.addEventListener("DOMContentLoaded", () => {
      resolve(createConfig(widgetName, scriptTagContainer.scriptParams))
    })
  })
}

let widgetName = getWidgetName(null)
let scriptTagContainer = getContainerFromCurrentScript(widgetName)

createNewConfig(widgetName, scriptTagContainer.scriptParams).then((config) => {
  // configureAjaxHelper(config.ajaxHelper)
  configureAjaxHelper({
    baseURL: scriptTagContainer.scriptParams.url,
  })
  setPolicy(config.policy)
  ReactDOM.render(React.createElement(App), scriptTagContainer.reactContainer)
})
