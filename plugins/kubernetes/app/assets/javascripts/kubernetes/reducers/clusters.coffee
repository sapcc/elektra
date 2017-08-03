((app) ->
  ########################### EVENTS ##############################
  initialKubernikusState =
    error: null
    total: 0
    items: []
    isFetching: false



  requestClusters = (state,{}) ->
    ReactHelpers.mergeObjects({},state,{
      isFetching: true
    })

  requestClustersFailure = (state,{error})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      error: error
    })

  receiveClusters = (state,{clusters,total})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: clusters
      error: null
    })






  # clusters reducer
  app.clusters = (state = initialKubernikusState, action) ->
    switch action.type
      when app.REQUEST_CLUSTERS            then requestClusters(state,action)
      when app.REQUEST_CLUSTERS_FAILURE    then requestClustersFailure(state,action)
      when app.RECEIVE_CLUSTERS            then receiveClusters(state,action)

      else state

)(kubernetes)
