/* eslint-disable no-undef */
import React from "react"
import { createStore, applyMiddleware, compose } from "redux"
import { Provider } from "react-redux"
import ReduxThunk from "redux-thunk"
import AppReducers from "./reducers/index"
import App from "./components/app.jsx"
import { setAjaxHelper, setBackendAjaxClient } from "./actions/ajax_helper"
import { createWidget } from "lib/widget"

composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
store = createStore(AppReducers, composeEnhancers(applyMiddleware(ReduxThunk)))

const AppProvider = ({ permissions, token, kubernikusBaseUrl }) => {
  setAjaxHelper(new ReactAjaxHelper(kubernikusBaseUrl, { authToken: token }))
  setBackendAjaxClient(
    new ReactAjaxHelper(
      `${window.location.origin}/${window.scopedDomainFid}/${window.scopedProjectFid}`
    )
  )

  return (
    <Provider store={store}>
      <App permissions={permissions} kubernikusBaseUrl={kubernikusBaseUrl} />
    </Provider>
  )
}

createWidget()
  .then((widget) => {
    widget.setPolicy()
    widget.render(AppProvider)
  })
  .catch((e) => console.error(e))
