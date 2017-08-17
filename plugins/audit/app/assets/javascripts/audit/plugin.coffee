#= require react/helpers
#= require moment.min
#= require react-datetime
#= require audit/constants
#= require audit/reducers/index
#= require audit/actions/index
#= require audit/components/app
#= require audit/helpers/data-format-helpers
#= require audit/helpers/checks


{ createStore, applyMiddleware, compose } = Redux
{ Provider, connect } = ReactRedux
{ AppReducers, App, fetchEvents } = audit


composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
store = createStore(AppReducers, composeEnhancers(applyMiddleware(ReduxThunk.default)))

AppProvider = ({permissions, token, eventsApi}) ->
  audit.ajaxHelper = new ReactAjaxHelper(eventsApi, authToken: token)
  React.createElement Provider, store: store,
    React.createElement App, {permissions: permissions}

audit.AppProvider = AppProvider
