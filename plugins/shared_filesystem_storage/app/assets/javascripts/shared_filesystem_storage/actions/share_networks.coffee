((app) ->
  #################### SHARE_NETWORKS #########################
  showShareNetworkModal= (shareNetwork) ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'SHOW_SHARE_NETWORK',
    modalProps: {shareNetwork}

  newShareNetworkModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'NEW_SHARE_NETWORK'

  editShareNetworkModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'EDIT_SHARE_NETWORK'

  requestShareNetworks= () ->
    type: app.REQUEST_SHARE_NETWORKS

  requestShareNetworksFailure= () ->
    type: app.REQUEST_SHARE_NETWORKS_FAILURE

  receiveShareNetworks= (json) ->
    type: app.RECEIVE_SHARE_NETWORKS
    shareNetworks: json
    receivedAt: Date.now()

  requestShareNetwork= (shareNetworkId) ->
    type: app.REQUEST_SHARE_NETWORK
    shareNetworkId: shareNetworkId

  requestShareNetworkFailure= (shareNetworkId) ->
    type: app.REQUEST_SHARE_NETWORK_FAILURE
    shareNetworkId: shareNetworkId

  receiveShareNetwork= (json) ->
    type: app.RECEIVE_SHARE_NETWORK
    shareNetwork: json

  fetchShareNetworks= () ->
    (dispatch) ->
      dispatch(requestShareNetworks())
      app.ajaxHelper.get '/share-networks',
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveShareNetworks(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestShareNetworksFailure())
          dispatch(app.showErrorDialog(title: 'Could not load share networks', message:jqXHR.responseText))

  shouldFetchShareNetworks= (state) ->
    shareNetworks = state.shareNetworks
    if shareNetworks.isFetching or shareNetworks.receivedAt
      false
    else if !shareNetworks.items or !shareNetworks.items.length
      true
    else
      false

  fetchShareNetworksIfNeeded= () ->
    (dispatch, getState) ->
      dispatch(fetchShareNetworks()) if shouldFetchShareNetworks(getState())

  requestDelete=(shareNetworkId) ->
    type: app.REQUEST_DELETE_SHARE_NETWORK
    shareNetworkId: shareNetworkId

  deleteShareNetworkFailure=(shareNetworkId) ->
    type: app.DELETE_SHARE_NETWORK_FAILURE
    shareNetworkId: shareNetworkId

  removeShareNetwork=(shareNetworkId) ->
    type: app.DELETE_SHARE_NETWORK_SUCCESS
    shareNetworkId: shareNetworkId

  showDeleteShareNetworkError=(shareNetworkId,message)->
    (dispatch) ->
      dispatch(deleteShareNetworkFailure(shareNetworkId))
      dispatch(app.showErrorDialog(title: 'Could not delete share network', message: message))

  deleteShareNetwork= (shareNetworkId) ->
    (dispatch, getState) ->
      dispatch(requestDelete(shareNetworkId))
      app.ajaxHelper.delete "/share-networks/#{shareNetworkId}",
        success: (data, textStatus, jqXHR) ->
          if data and data.errors
            dispatch(showDeleteShareNetworkError(shareNetworkId,ReactFormHelpers.Errors(data)))
          else
            dispatch(removeShareNetwork(shareNetworkId))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(showDeleteShareNetworkError(shareNetworkId,jqXHR.responseText))


  openDeleteShareNetworkDialog=(shareNetworkId, options={}) ->
    (dispatch, getState) ->
      networkShares = []
      for s in getState().shares.items
        networkShares.push(s) if s.share_network_id==shareNetworkId

      if networkShares.length==0
        dispatch(app.showConfirmDialog({
          message: options.message || 'Do you really want to delete this share network?' ,
          confirmCallback: (() -> dispatch(deleteShareNetwork(shareNetworkId)))
        }))
      else
        dispatch(app.showInfoDialog(title: 'Existing Dependencies', message: "Please delete dependent shares(#{networkShares.length}) first!"))

  openNewShareNetworkDialog=()->
    (dispatch) ->
      dispatch(shareNetworkFormForCreate())
      dispatch(newShareNetworkModal())

  openEditShareNetworkDialog=(shareNetwork)->
    (dispatch) ->
      dispatch(shareNetworkFormForUpdate(shareNetwork))
      dispatch(editShareNetworkModal())

  ################# SHARSHARE_NETWORKE FORM ###################
  resetShareNetworkForm=()->
    type: app.RESET_SHARE_NETWORK_FORM

  shareNetworkFormForCreate=()->
    type: app.PREPARE_SHARE_NETWORK_FORM
    method: 'post'
    action: "/share-networks"

  shareNetworkFormForUpdate=(shareNetwork) ->
    type: app.PREPARE_SHARE_NETWORK_FORM
    data: shareNetwork
    method: 'put'
    action: "/share-networks/#{shareNetwork.id}"

  shareNetworkFormFailure=(errors) ->
    type: app.SHARE_NETWORK_FORM_FAILURE
    errors: errors

  updateShareNetworkForm= (name,value) ->
    type: app.UPDATE_SHARE_NETWORK_FORM
    name: name
    value: value

  submitShareNetworkForm= (successCallback=null) ->
    (dispatch, getState) ->
      shareNetworkForm = getState().shareNetworkForm
      if shareNetworkForm.isValid
        dispatch(type: app.SUBMIT_SHARE_NETWORK_FORM)
        app.ajaxHelper[shareNetworkForm.method] shareNetworkForm.action,
          data: { share_network: shareNetworkForm.data }
          success: (data, textStatus, jqXHR) ->
            if data.errors
              dispatch(shareNetworkFormFailure(data.errors))
            else
              dispatch(receiveShareNetwork(data))
              dispatch(resetShareNetworkForm())
              successCallback() if successCallback
          error: ( jqXHR, textStatus, errorThrown) ->
            dispatch(app.showErrorDialog(title: 'Could not save share network', message:jqXHR.responseText))

  ######################## NETWORKS ###########################
  # Neutron Networks, Not Share Networks!!!
  shouldFetchNetworks= (state) ->
    networks = state.networks
    if networks.isFetching or networks.receivedAt
      false
    else if !networks.items or !networks.items.length
      true
    else
      false
  requestNetworks= () ->
    type: app.REQUEST_NETWORKS

  requestNetworksFailure= () ->
    type: app.REQUEST_NETWORKS_FAILURE

  receiveNetworks= (json) ->
    type: app.RECEIVE_NETWORKS
    networks: json
    receivedAt: Date.now()

  fetchNetworks=() ->
    (dispatch) ->
      dispatch(requestNetworks())
      app.ajaxHelper.get '/share-networks/networks',
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveNetworks(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestNetworksFailure())

  fetchNetworksIfNeeded= () ->
    (dispatch, getState) ->
      dispatch(fetchNetworks()) if shouldFetchNetworks(getState())

  ###################### NEUTRON SUBNETS ########################
  requestNetworkSubnets= (networkId) ->
    type: app.REQUEST_SUBNETS
    networkId: networkId

  receiveNetworkSubnets= (networkId, json) ->
    type: app.RECEIVE_SUBNETS
    networkId: networkId
    subnets: json
    receivedAt: Date.now()

  fetchNetworkSubnets= (networkId) ->
    (dispatch) ->
      dispatch(requestNetworkSubnets(networkId))
      app.ajaxHelper.get "/share-networks/subnets",
        data: {network_id: networkId}
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveNetworkSubnets(networkId,data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestNetworkSubnetsFailure(networkId))

  shouldFetchNetworkSubnets= (state, networkId) ->
    subnets = state.subnets[networkId]
    if !subnets
      true
    else if subnets.isFetching or subnets.receivedAt
      false
    else
      false

  fetchNetworkSubnetsIfNeeded= (networkId) ->
    (dispatch, getState) ->
      dispatch(fetchNetworkSubnets(networkId)) if shouldFetchNetworkSubnets(getState(), networkId)

  # export
  app.fetchNetworksIfNeeded              = fetchNetworksIfNeeded
  app.fetchNetworkSubnetsIfNeeded        = fetchNetworkSubnetsIfNeeded
  app.fetchShareNetworks                 = fetchShareNetworks
  app.fetchShareNetworksIfNeeded         = fetchShareNetworksIfNeeded
  app.deleteShareNetwork                 = deleteShareNetwork
  app.openNewShareNetworkDialog          = openNewShareNetworkDialog
  app.openDeleteShareNetworkDialog       = openDeleteShareNetworkDialog
  app.openEditShareNetworkDialog         = openEditShareNetworkDialog
  app.openShowShareNetworkDialog         = showShareNetworkModal

  app.shareNetworkFormForCreate          = shareNetworkFormForCreate
  app.shareNetworkFormForUpdate          = shareNetworkFormForUpdate
  app.submitShareNetworkForm             = submitShareNetworkForm
  app.updateShareNetworkForm             = updateShareNetworkForm
)(shared_filesystem_storage)
