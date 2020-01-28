import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import { getWidgetName, getContainerFromCurrentScript, createConfig } from 'widget'
import { configureAjaxHelper } from 'ajax_helper';
import { setPolicy } from 'policy';

let widgetName = getWidgetName(__dirname)
let scriptTagContainer = getContainerFromCurrentScript(widgetName)
let ajaxConfig = createConfig(scriptTagContainer.scriptParams, widgetName).ajaxHelper

configureAjaxHelper(ajaxConfig)

setPolicy()

ReactDOM.render(<App />, scriptTagContainer.reactContainer);
