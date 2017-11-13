((app)->
  activeTab = (state = {}, action) ->
    switch action.type
      when app.SELECT_TAB
        uid: action.uid
      else
        return state

  # export
  app.activeTab = activeTab      
)(shared_filesystem_storage)
