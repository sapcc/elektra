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

  addCluster = (cluster) ->
    type: app.ADD_CLUSTER
    cluster: cluster

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
        console.log('dispatch submit')
        app.ajaxHelper[clusterForm.method] clusterForm.action,
          contentType: 'application/json'
          data: clusterForm.data

          success: (data, textStatus, jqXHR) ->
            console.log('success!')
            dispatch(resetClusterForm())
            console.log('resetClusterForm')
            dispatch(addCluster(data))
            console.log('addCluster')
            successCallback() if successCallback
            console.log('successCallback')
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

  app.clusterFormForCreate       = clusterFormForCreate
  app.clusterFormForUpdate       = clusterFormForUpdate
  app.submitClusterForm          = submitClusterForm
  app.updateClusterForm          = updateClusterForm




)(kubernetes)
