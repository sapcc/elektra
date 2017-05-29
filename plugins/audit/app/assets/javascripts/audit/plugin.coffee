#= require react/helpers
#= require audit/constants
#= require audit/reducers/index
#= require audit/actions/index
#= require audit/components/app

{ createStore, applyMiddleware, compose } = Redux
{ Provider, connect } = ReactRedux
{ AppReducers, App, fetchEvents } = audit


composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
store = createStore(AppReducers, composeEnhancers(applyMiddleware(ReduxThunk.default)))

AppProvider = ({permissions}) ->
  React.createElement Provider, store: store,
    React.createElement App, permissions: permissions

audit.AppProvider = AppProvider
