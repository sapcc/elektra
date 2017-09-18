((app) ->
  ########################### CLUSTERS ##############################
  initialKubernikusState =
    error: null
    total: 0
    items: []
    isFetching: false


  # ----- list ------
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

  # ----- item ------
  requestCluster = (state,{}) ->
    # ReactHelpers.mergeObjects({},state,{
    #   isFetching: true
    # })

  requestClusterFailure = (state,{error})->
    # ReactHelpers.mergeObjects({},state,{
    #   isFetching: false
    #   error: error
    # })


  receiveCluster = (state, {cluster}) ->
    index = ReactHelpers.findIndexInArray(state.items,cluster.name, 'name')
    items = state.items.slice()
    # update or add
    if index>=0 then items[index]=cluster else items.push cluster
    ReactHelpers.mergeObjects({},state,{items})

    # clusters = ReactHelpers.mergeObjects({},state.items,cluster)
    # ReactHelpers.mergeObjects({},state,{
    #   items: clusters
    # })


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
    console.log(action.type)
    switch action.type
      when app.REQUEST_CLUSTERS             then requestClusters(state,action)
      when app.REQUEST_CLUSTERS_FAILURE     then requestClustersFailure(state,action)
      when app.RECEIVE_CLUSTERS             then receiveClusters(state,action)
      when app.RECEIVE_CLUSTER                  then receiveCluster(state,action)
      when app.DELETE_CLUSTER               then deleteCluster(state,action)
      when app.DELETE_CLUSTER_FAILURE       then deleteClusterFailure(state,action)

      else state

)(kubernetes)
