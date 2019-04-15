#= require_tree .

{ combineReducers } = Redux

((app) ->
  app.AppReducers = combineReducers({
    modals:        ReactModal.Reducer,
    clusters:      app.clusters,
    clusterForm:   app.clusterForm,
    metaData:      app.metaData,
    info:          app.info

  })
)(kubernetes)
