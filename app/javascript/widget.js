/* eslint no-console:0 */
import "babel-polyfill";
// import 'core-js'

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


class Widget {
  constructor(reactContainer, config) {
    this.reactContainer = reactContainer
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
    container = React.createElement(container, this.config.scriptParams)

    if(this.store) {
      ReactDOM.render(
        <Provider store = { this.store }>
          <React.Fragment><FlashMessages/>{ container }</React.Fragment>
        </Provider>, this.reactContainer
      )
    } else {
      ReactDOM.render(
        <React.Fragment><FlashMessages/>{ container }</React.Fragment>, this.reactContainer
      )
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
  const currentScript = getCurrentScript(widgetName)
  const scriptParams = Object.assign({}, currentScript.dataset)
  const srcTokens = currentScript && currentScript.getAttribute('src') ? currentScript.getAttribute('src').split('/') : []
  const reactContainer = window.document.createElement('div');

  let htmlOptions = options.html || {};
  let defaultHtmlOptions = {class: '.react-widget-content'};
  htmlOptions = Object.assign({}, defaultHtmlOptions, htmlOptions);
  for(let attr in htmlOptions) {
    reactContainer.setAttribute(attr, htmlOptions[attr]);
  }

  currentScript.parentNode.replaceChild(reactContainer, currentScript);

  const createConfig = () => (
    {
      scriptParams: scriptParams,
      devOptions: { name: srcTokens[srcTokens.length-1] },
      ajaxHelper: {
        baseURL: `${window.location.origin}${window.location.pathname}`,
        headers: {}
      },
      policy: window.policy
    }
  )

  // if document is already loaded then resolve Promise immediately
  // with a new widget object
  if (document.readyState === "complete")
    return Promise.resolve(new Widget(reactContainer, createConfig()))

  // document is not loaded yet -> create a new Promise and resolve it as soon
  // as document is loaded.
  return new Promise((resolve, reject) => {
    document.addEventListener('DOMContentLoaded', () => {
      resolve(new Widget(reactContainer, createConfig()))
    })
  })
}
