#= require_tree .

{ combineReducers } = Redux

((app) ->
  app.AppReducers = combineReducers({
    clusters:             app.clusters
  })
)(kubernetes)
