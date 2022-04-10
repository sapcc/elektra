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
  configureAjaxHelper(config.ajaxHelper)
  setPolicy(config.policy)
  ReactDOM.render(React.createElement(App), scriptTagContainer.reactContainer)
})
