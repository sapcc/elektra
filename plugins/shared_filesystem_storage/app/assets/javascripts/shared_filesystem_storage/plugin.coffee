#= require react/modal
#= require shared_filesystem_storage/constants
#= require shared_filesystem_storage/actions/index
#= require shared_filesystem_storage/reducers/index
#= require shared_filesystem_storage/components/app

{ createStore, applyMiddleware, compose } = Redux
{ Provider, connect } = ReactRedux
{ AppReducers, App, selectTab } = shared_filesystem_storage

composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
store = createStore(AppReducers, composeEnhancers(applyMiddleware(ReduxThunk.default)))

store.dispatch(selectTab(window.location.hash.replace('#','')))

AppProvider = ({permissions}) ->
  React.createElement Provider, store: store,
    React.createElement App, permissions: permissions

shared_filesystem_storage.AppProvider = AppProvider
