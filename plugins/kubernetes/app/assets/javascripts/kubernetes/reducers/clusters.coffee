((app) ->
  ########################### CLUSTERS ##############################
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

  receiveClusters = (state,{clusters})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: clusters
      error: null
    })


  deleteCluster = (state,{clusterName}) ->
    ReactHelpers.mergeObjects({},state,{
      deleteTarget: clusterName
    })

  deleteClusterFailure = (state,{clusterName, error})->
    ReactHelpers.mergeObjects({},state,{
      deleteTarget: ''
      error: error
    })




  # clusters reducer
  app.clusters = (state = initialKubernikusState, action) ->
    switch action.type
      when app.REQUEST_CLUSTERS             then requestClusters(state,action)
      when app.REQUEST_CLUSTERS_FAILURE     then requestClustersFailure(state,action)
      when app.RECEIVE_CLUSTERS             then receiveClusters(state,action)
      when app.DELETE_CLUSTER               then deleteCluster(state,action)
      when app.DELETE_CLUSTER_FAILURE       then deleteClusterFailure(state,action)

      else state

)(kubernetes)
