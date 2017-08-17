#= require_tree .

{ combineReducers } = Redux

((app) ->
  app.AppReducers = combineReducers({
    events:             app.events
  })
)(audit)
