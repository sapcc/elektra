/* eslint no-console:0 */
import "babel-polyfill";

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
          <div><FlashMessages/>{ container }</div>
        </Provider>, this.reactContainer
      )
    } else {
      ReactDOM.render(
        <div><FlashMessages/>{ container }</div>, this.reactContainer
      )
    }
  }
}

export const createWidget = () => {
  let scripts = document.getElementsByTagName( 'script' );
  const currentScript = scripts[ scripts.length - 1 ];

  return new Promise((resolve, reject) => {
    document.addEventListener('DOMContentLoaded', () => {
      const scriptParams = Object.assign({}, currentScript.dataset)
      const srcTokens = currentScript.getAttribute('src').split('/')

      const reactContainer = window.document.createElement('div');
      currentScript.parentNode.replaceChild(reactContainer, currentScript);

      let config = {
        scriptParams: scriptParams,
        devOptions: { name: srcTokens[srcTokens.length-1] },
        ajaxHelper: {
          baseURL: `${window.location.origin}${window.location.pathname}`,
          headers: {}
        },
        policy: window.policy
      }

      resolve(new Widget(reactContainer, config))
    })
  })
}
