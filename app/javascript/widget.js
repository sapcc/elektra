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


export function renderWidget(name, container, reducers) {
  let scripts = document.getElementsByTagName( 'script' );
  let currentScript = scripts[ scripts.length - 1 ];

  const store = createWidgetStore({name: name, reducers: reducers})
  const reactContainer = window.document.createElement('div');
  currentScript.parentNode.replaceChild(reactContainer, currentScript);

  document.addEventListener('DOMContentLoaded', () => {
    configureAjaxHelper(window);
    setPolicy(window.policy);

    ReactDOM.render(
      <Provider store = { store }>
        <div>
          <FlashMessages/>
          { React.createElement(container) }
        </div>
      </Provider>, reactContainer
    )
  })
}

let count = 0
export function createWidgetStore(options) {
  let dev_options = { name: options.name || `Widget ${count++}` }
  const composeEnhancers = composeWithDevTools(dev_options);
  return createStore(combineReducers(options.reducers), /* preloadedState, */ composeEnhancers(
    applyMiddleware(ReduxThunk),
    // other store enhancers if any
  ));
}
