((app) ->
  #################### CLUSTERS #########################

  requestClusters = () ->
    type: app.REQUEST_CLUSTERS

  requestClustersFailure = (error) ->
    type: app.REQUEST_CLUSTERS_FAILURE
    error: error

  receiveClusters = (json, total) ->
    type: app.RECEIVE_CLUSTERS
    clusters: json
    total: total

  loadClusters = () ->
    (dispatch, getState) ->
      currentState    = getState()
      clusters        = currentState.clusters
      isFetching      = clusters.isFetching


      return if isFetching # don't fetch if we're already fetching
      dispatch(requestClusters())

      app.ajaxHelper.get '/clusters',
        contentType: 'application/json'
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveClusters(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestClustersFailure(errorThrown))



  fetchClusters = () ->
    (dispatch) ->
      dispatch(loadClusters())


  # -------------- CREATE ---------------

  # newCluster = (options) ->
  #   (dispatch) ->
  #     dispatch()


  # -------------- DELETE ---------------

  requestDeleteCluster = (clusterName) ->
    (dispatch) ->
      # TODO: show confirm dialog
      dispatch(deleteCluster(clusterName))

      app.ajaxHelper.delete "/clusters/#{clusterName}",
        contentType: 'application/json'
        success: (data, textStatus, jqXHR) ->
          dispatch(fetchClusters())
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(deleteClusterFailure(clusterName, errorThrown))


  deleteCluster = () ->
    type: app.DELETE_CLUSTER

  deleteClusterFailure = (error) ->
    type: app.DELETE_CLUSTER_FAILURE
    error: error

  # export
  app.fetchClusters                 = fetchClusters
  app.requestDeleteCluster          = requestDeleteCluster



)(kubernetes)
