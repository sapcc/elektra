// import { createWidget } from "widget"
// import * as reducers from "./reducers"
// import App from "./components/application"

// createWidget(__dirname).then((widget) => {
//   widget.configureAjaxHelper({
//     baseURL: widget.config.scriptParams.url,
//   })
//   widget.setPolicy()
//   widget.createStore(reducers)
//   widget.render(App)
// })

import React from "react"
import ReactDOM from "react-dom"
import App from "./App"
import {
  getWidgetName,
  getContainerFromCurrentScript,
  createConfig,
} from "widget"
import { configureAjaxHelper } from "ajax_helper"
import { setPolicy } from "policy"

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

let widgetName = getWidgetName(__dirname)
let scriptTagContainer = getContainerFromCurrentScript(widgetName)

createNewConfig(widgetName, scriptTagContainer.scriptParams).then((config) => {
  // configureAjaxHelper(config.ajaxHelper)
  configureAjaxHelper({
    baseURL: scriptTagContainer.scriptParams.url,
  })
  setPolicy(config.policy)
  ReactDOM.render(<App />, scriptTagContainer.reactContainer)
})
