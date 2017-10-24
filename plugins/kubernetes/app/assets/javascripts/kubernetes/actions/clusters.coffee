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
          errorMessage =  if typeof jqXHR.responseJSON == 'object'
                            JSON.parse(jqXHR.responseText).message
                          else
                            if jqXHR.responseText.length > 0
                              jqXHR.responseText
                            else
                              "The backend is currently slow to respond. Please try again later. We are on it."


          dispatch(requestClustersFailure(errorMessage))



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

  startPollingCluster = (clusterName) ->
    type: app.START_POLLING_CLUSTER
    clusterName: clusterName

  stopPollingCluster = (clusterName) ->
    type: app.STOP_POLLING_CLUSTER
    clusterName: clusterName


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
            else
              errorMessage =  if typeof jqXHR.responseJSON == 'object'
                                JSON.parse(jqXHR.responseText).message
                              else jqXHR.responseText
              dispatch(requestClusterFailure(errorMessage))



  # -------------- CREATE ---------------

  newClusterModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'NEW_CLUSTER'

  openNewClusterDialog = () ->
    (dispatch) ->
      dispatch(clusterFormForCreate())
      dispatch(newClusterModal())


  # -------------- EDIT ---------------

  editClusterModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'EDIT_CLUSTER'

  openEditClusterDialog = (cluster) ->
    (dispatch) ->
      dispatch(clusterFormForUpdate(cluster))
      dispatch(editClusterModal())


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
          errorMessage =  if typeof jqXHR.responseJSON == 'object'
                            JSON.parse(jqXHR.responseText).message
                          else jqXHR.responseText
          dispatch(deleteClusterFailure(clusterName, errorMessage))


  deleteCluster = () ->
    type: app.DELETE_CLUSTER

  deleteClusterFailure = (error) ->
    type: app.DELETE_CLUSTER_FAILURE
    error: error


  # -------------- CREDENTIALS ---------------

  getCredentials = (clusterName) ->
    (dispatch) ->
      dispatch(requestCredentials(clusterName))

      app.ajaxHelper.get "/clusters/#{clusterName}/credentials",
        contentType: 'application/json'
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveCredentials(clusterName, data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestCredentialsFailure(clusterName, jqXHR.responseText))


  requestCredentials = () ->
    type: app.REQUEST_CREDENTIALS

  requestCredentialsFailure = (clusterName, error) ->
    type: app.REQUEST_CREDENTIALS_FAILURE
    flashError: "We couldn't retrieve the credentials for cluster #{clusterName} at this time. This might be because the cluster is not ready yet or is in an error state. Please try again."

  receiveCredentials = (clusterName, credentials) ->
    (dispatch) ->
      blob = new Blob([credentials.kubeconfig], {type: "application/x-yaml;charset=utf-8"})
      saveAs(blob, "#{clusterName}-config")



  # -------------- SETUP ---------------

  getSetupInfo = (clusterName) ->
    (dispatch) ->
      dispatch(requestSetupInfo(clusterName))

      app.ajaxHelper.get "/clusters/#{clusterName}/credentials",
        contentType: 'application/json'
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveSetupInfo(clusterName, data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestSetupInfoFailure(clusterName, jqXHR.responseText))
          dispatch(receiveSetupInfo(clusterName, "thisisdata"))



  requestSetupInfo = () ->
    type: app.REQUEST_SETUP_INFO

  requestSetupInfoFailure = (clusterName, error) ->
    type: app.REQUEST_SETUP_INFO_FAILURE
    flashError: "We couldn't retrieve the setup information for cluster #{clusterName} at this time. This might be because the cluster is not ready yet or is in an error state. Please try again."

  receiveSetupInfo = (clusterName, setupInfo) ->
    (dispatch) ->
      dispatch(dataForSetupInfo(setupInfo))
      dispatch(setupInfoModal())


  setupInfoModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'SETUP_INFO'

  dataForSetupInfo = (data) ->
    type: app.SETUP_INFO_DATA
    setupData: data



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

  updateNodePoolForm = (index, name, value) ->
    type: app.UPDATE_NODE_POOL_FORM
    index: index
    name: name
    value: value

  addNodePool = () ->
    type: app.ADD_NODE_POOL

  deleteNodePool = (index) ->
    type: app.DELETE_NODE_POOL
    index: index


  submitClusterForm = (successCallback=null) ->
    (dispatch, getState) ->
      clusterForm = getState().clusterForm
      console.log(clusterForm)
      if clusterForm.isValid
        dispatch(type: app.SUBMIT_CLUSTER_FORM)
        app.ajaxHelper[clusterForm.method] clusterForm.action,
          contentType: 'application/json'
          data: clusterForm.data

          success: (data, textStatus, jqXHR) ->
            dispatch(resetClusterForm())
            dispatch(receiveCluster(data))
            successCallback() if successCallback
          error: ( jqXHR, textStatus, errorThrown) ->
            errorMessage =  if typeof jqXHR.responseJSON == 'object'
                              JSON.parse(jqXHR.responseText).message
                            else jqXHR.responseText

            dispatch(clusterFormFailure("Please Note": [errorMessage]))

            # dispatch(app.showErrorDialog(title: 'Could not save cluster', message:jqXHR.responseText))


  # export
  app.fetchClusters              = fetchClusters
  app.requestDeleteCluster       = requestDeleteCluster
  app.openNewClusterDialog       = openNewClusterDialog
  app.openEditClusterDialog      = openEditClusterDialog
  app.loadCluster                = loadCluster
  app.getCredentials             = getCredentials
  app.getSetupInfo               = getSetupInfo
  app.clusterFormForCreate       = clusterFormForCreate
  app.clusterFormForUpdate       = clusterFormForUpdate
  app.submitClusterForm          = submitClusterForm
  app.updateClusterForm          = updateClusterForm
  app.updateNodePoolForm         = updateNodePoolForm
  app.addNodePool                = addNodePool
  app.deleteNodePool             = deleteNodePool
  app.startPollingCluster        = startPollingCluster
  app.stopPollingCluster         = stopPollingCluster




)(kubernetes)
