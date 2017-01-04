((app) ->
  selectTab= (uid) ->
    type: app.SELECT_TAB
    uid: uid

  # export
  app.selectTab = selectTab
)(shared_filesystem_storage)
