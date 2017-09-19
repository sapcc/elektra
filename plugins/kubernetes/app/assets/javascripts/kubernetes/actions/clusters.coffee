((app) ->
  #################### CLUSTERS #########################

  # ---- list ----
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


  # ---- item ----
  requestCluster = (clusterName) ->
    type: app.REQUEST_CLUSTER
    clusterName: clusterName

  requestClusterFailure = (error) ->
    type: app.REQUEST_CLUSTER_FAILURE
    error: error

  receiveCluster = (cluster) ->
    type: app.RECEIVE_CLUSTER
    cluster: cluster

  loadCluster = (clusterName) ->
    (dispatch, getState) ->
      # currentState    = getState()
      # cluster         = currentState.clusters
      # isFetching      = clusters.isFetching


      # return if isFetching # don't fetch if we're already fetching
      dispatch(requestCluster(clusterName))

      app.ajaxHelper.get "/clusters/#{clusterName}",
        contentType: 'application/json'
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveCluster(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          switch jqXHR.status
            when 404 then dispatch(loadClusters()) # if requested cluster not found reload the whole list to see what we have
            else dispatch(requestClusterFailure(jqXHR.responseText))



  # -------------- CREATE ---------------

  newClusterModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'NEW_CLUSTER'

  openNewClusterDialog = () ->
    console.log("openNewClusterDialog")
    (dispatch) ->
      dispatch(clusterFormForCreate())
      dispatch(newClusterModal())


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


  ################# CLUSTER FORM ######################

  clusterFormForCreate = () ->
    type: app.PREPARE_CLUSTER_FORM
    method: 'post'
    action: "/clusters"

  resetClusterForm = () ->
    type: app.RESET_CLUSTER_FORM

  clusterFormForUpdate = (cluster) ->
    type: app.PREPARE_CLUSTER_FORM
    data: cluster
    method: 'put'
    action: "/clusters/#{cluster.name}"

  clusterFormFailure = (errors) ->
    type: app.CLUSTER_FORM_FAILURE
    errors: errors

  updateClusterForm = (name,value) ->
    type: app.UPDATE_CLUSTER_FORM
    name: name
    value: value

  submitClusterForm = (successCallback=null) ->
    (dispatch, getState) ->
      clusterForm = getState().clusterForm
      if clusterForm.isValid
        dispatch(type: app.SUBMIT_CLUSTER_FORM)
        app.ajaxHelper[clusterForm.method] clusterForm.action,
          contentType: 'application/json'
          data: clusterForm.data

          success: (data, textStatus, jqXHR) ->
            console.log("data: ", data)
            dispatch(resetClusterForm())
            dispatch(receiveCluster(data))
            successCallback() if successCallback
          error: ( jqXHR, textStatus, errorThrown) ->
            console.log('error', jqXHR, jqXHR.status, typeof jqXHR.responseText == 'object')
            errorMessage =  if typeof jqXHR.responseText == 'object'
                              JSON.parse(jqXHR.responseText).message
                            else 'The connection to the backend service is currently slow. Please try again.'

            dispatch(clusterFormFailure("Please Note": [errorMessage]))

            # dispatch(app.showErrorDialog(title: 'Could not save cluster', message:jqXHR.responseText))


  # export
  app.fetchClusters              = fetchClusters
  app.requestDeleteCluster       = requestDeleteCluster
  app.openNewClusterDialog       = openNewClusterDialog
  app.loadCluster                = loadCluster
  app.clusterFormForCreate       = clusterFormForCreate
  app.clusterFormForUpdate       = clusterFormForUpdate
  app.submitClusterForm          = submitClusterForm
  app.updateClusterForm          = updateClusterForm




)(kubernetes)
