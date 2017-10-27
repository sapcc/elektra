
#= require components/modal
#= require components/helpers
#= require kubernetes/constants
#= require kubernetes/reducers/index
#= require kubernetes/actions/index
#= require kubernetes/components/app
#= require kubernetes/helpers/js_helpers
#= require filesaver



{ createStore, applyMiddleware, compose } = Redux
{ Provider, connect } = ReactRedux
{ AppReducers, App } = kubernetes


composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
store = createStore(AppReducers, composeEnhancers(applyMiddleware(ReduxThunk.default)))

AppProvider = ({permissions, token, kubernikusBaseUrl}) ->
  kubernetes.ajaxHelper = new ReactAjaxHelper(kubernikusBaseUrl, authToken: token)
  React.createElement Provider, store: store,
    React.createElement App, {permissions: permissions, kubernikusBaseUrl: kubernikusBaseUrl}


kubernetes.AppProvider = AppProvider
