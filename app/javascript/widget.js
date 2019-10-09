/* eslint no-console:0 */
// https://babeljs.io/docs/en/babel-polyfill
import "@babel/polyfill";


import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { FlashMessages } from 'lib/flashes';
import dialogs from 'lib/dialogs';

import { createStore, combineReducers, applyMiddleware } from 'redux'
import ReduxThunk from 'redux-thunk'
import { composeWithDevTools } from 'redux-devtools-extension'
import { setPolicy } from 'policy';
import { configureAjaxHelper } from 'ajax_helper';

const isIterable = (obj) => {
  // checks for null and undefined
  if (obj == null) {
    return false;
  }
  return typeof obj[Symbol.iterator] === 'function';
}

const getDataset = (element) => {
  const set = {}
  for(let a of element.attributes) {
    if(a.name.indexOf('data-')==0) set[a.name] = a.value
  }
  return set
}

const setAttributes = (element, attributes) => {
  for(let key of attributes) element.setAttribute(key,attributes[key])
}

class Widget {
  constructor(reactContainers, config) {
    // reactContainers should always be an array (support global widgets)
    this.reactContainers = isIterable(reactContainers) ? reactContainers : [reactContainers]
    this.config = config
    this.createStore = this.createStore.bind(this)
    this.render = this.render.bind(this)
    this.configureAjaxHelper = this.configureAjaxHelper.bind(this)
    this.setPolicy = this.setPolicy.bind(this)
  }

  createStore(reducers){
    const devOptions = this.config.devOptions || {}
    const composeEnhancers = composeWithDevTools(devOptions);

    this.store = createStore(combineReducers(reducers), /* preloadedState, */ composeEnhancers(
      applyMiddleware(ReduxThunk),
      // other store enhancers if any
    ));
  }

  configureAjaxHelper(options) {
    options = options || {}
    const ajaxHelperOptions = Object.assign({},this.config.ajaxHelper,options)

    configureAjaxHelper(ajaxHelperOptions)
  }

  setPolicy(policy) {
    policy = policy || this.config.policy
    setPolicy(this.config.policy);
  }

  render(container){
    // const Container = React.createElement(container, this.config.params)

    for(let reactContainer of this.reactContainers) {
      let dataset = getDataset(reactContainer)
      let wrappedComponent = React.createElement(container, Object.assign({},dataset,this.config.params))

      if(this.store) {
        ReactDOM.render(
          <Provider store = { this.store }>
            <React.Fragment>
              { (this.config.params.flashescontainer !== "custom") && <FlashMessages/>}
              { wrappedComponent }
            </React.Fragment>
          </Provider>, reactContainer
        )
      } else {
        ReactDOM.render(
          <React.Fragment>
            { (this.config.params.flashescontainer !== "custom") && <FlashMessages/>}
            { wrappedComponent }
          </React.Fragment>, reactContainer
        )
      }
    }
  }
}

const getWidgetName = (dirname) => {
  if(!dirname) return null
  const name_regex = /.*plugins\/([^\/]+)\/app\/javascript\/([^\.]+)/
  const name_tokens = dirname.match(name_regex);
  if(name_tokens.length<2) return null
  return `${name_tokens[1]}_${name_tokens[2]}`
}

const getCurrentScript = (widgetName) => {
  if(widgetName) {
    let script = document.querySelector(`script[src*="/${widgetName}"]`);
    if(script) return script
  }
  let scripts = document.getElementsByTagName( 'script' );
  return scripts[ scripts.length - 1 ];
}

export const createWidget = (dirname, options={}) => {
  const widgetName = getWidgetName(dirname)
  let reactContainers = options.containers
  let params = options.params || {}

  if(!reactContainers) {
    let scriptTagContainer = getContainerFromCurrentScript(widgetName)
    reactContainers = [scriptTagContainer.reactContainer]
    params = scriptTagContainer.scriptParams
  }

  let htmlOptions = options.html || {};
  let defaultHtmlOptions = {class: '.react-widget-content'};
  htmlOptions = Object.assign({}, defaultHtmlOptions, htmlOptions);
  for(let attr in htmlOptions) {
    for(let reactContainer of reactContainers) {
      reactContainer.setAttribute(attr, htmlOptions[attr])
    }
  }

  const createConfig = () => {
    // get current url without params and bind it to baseURL
    let origin = window.location.origin
    if(!origin) {
      const originMatch = window.location.href.match(/(http(s)?:\/\/[^\/]+).*/)
      if (originMatch) origin = originMatch[1]
    }

    return {
      params,
      scriptParams: params,
      devOptions: { name: widgetName },
      ajaxHelper: {
        baseURL: `${origin}${window.location.pathname}`,
        headers: {}
      },
      policy: window.policy
    }
  }

  // if document is already loaded then resolve Promise immediately
  // with a new widget object
  if (document.readyState === "complete")
    return Promise.resolve(new Widget(reactContainers, createConfig()))

  // document is not loaded yet -> create a new Promise and resolve it as soon
  // as document is loaded.
  return new Promise((resolve, reject) => {
    document.addEventListener('DOMContentLoaded', () => {
      resolve(new Widget(reactContainers, createConfig()))
    })
  })
}


const getContainerFromCurrentScript = (widgetName) => {
  const currentScript = getCurrentScript(widgetName)
  const scriptParams = JSON.parse(JSON.stringify(currentScript.dataset))
  const srcTokens = currentScript && currentScript.getAttribute('src') ? currentScript.getAttribute('src').split('/') : []
  const reactContainer = window.document.createElement('div');

  currentScript.parentNode.replaceChild(reactContainer, currentScript);
  return {
    reactContainer,
    scriptParams
  }
}
