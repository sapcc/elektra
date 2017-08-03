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
        data: {}
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveClusters(data["clusters"],data["total"]))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestClustersFailure(errorThrown))



  fetchClusters = () ->
    (dispatch) ->
      dispatch(loadClusters())




  # export
  app.fetchClusters                 = fetchClusters


)(kubernetes)
