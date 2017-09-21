
#= require components/modal
#= require components/helpers
#= require kubernetes/constants
#= require kubernetes/reducers/index
#= require kubernetes/actions/index
#= require kubernetes/components/app
#= require kubernetes/helpers/js_helpers



{ createStore, applyMiddleware, compose } = Redux
{ Provider, connect } = ReactRedux
{ AppReducers, App } = kubernetes


composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
store = createStore(AppReducers, composeEnhancers(applyMiddleware(ReduxThunk.default)))

AppProvider = ({permissions, token, kubernikusApi}) ->
  kubernetes.ajaxHelper = new ReactAjaxHelper(kubernikusApi, authToken: token)
  React.createElement Provider, store: store,
    React.createElement App, {permissions: permissions}

kubernetes.AppProvider = AppProvider
