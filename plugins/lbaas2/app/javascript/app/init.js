import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import { getWidgetName, getContainerFromCurrentScript } from 'widget'
import { configureAjaxHelper } from 'ajax_helper';
import { setPolicy } from 'policy';

let widgetName = getWidgetName(__dirname)
let scriptTagContainer = getContainerFromCurrentScript(widgetName)

configureAjaxHelper(
  {
    baseURL: scriptTagContainer.scriptParams.url
  }
)

setPolicy()

ReactDOM.render(<App />, scriptTagContainer.reactContainer);
