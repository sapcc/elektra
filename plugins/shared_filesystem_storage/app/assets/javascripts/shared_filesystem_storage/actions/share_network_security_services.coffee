((app) ->
  ################# SHARE RULES (ACCESS CONTROL) ################
  showShareNetworkSecurityServicesDialog=(shareNetworkId) ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'SHARE_NETWORK_SECURITY_SERVICES',
    modalProps: {shareNetworkId}

  openShareNetworkSecurityServicesDialog=(shareNetworkId)->
    (dispatch) ->
      dispatch(app.shareNetworkSecurityServiceFormForCreate(shareNetworkId))
      dispatch(showShareNetworkSecurityServicesDialog(shareNetworkId))

  receiveShareNetworkSecurityService=(shareNetworkId,securityService)->
    type: app.RECEIVE_SHARE_NETWORK_SECURITY_SERVICE
    shareNetworkId: shareNetworkId
    securityService: securityService

  requestDeleteShareNetworkSecurityService=(shareNetworkId,securityServiceId) ->
    type: app.REQUEST_DELETE_SHARE_NETWORK_SECURITY_SERVICE
    shareNetworkId: shareNetworkId
    securityServiceId: securityServiceId

  deleteShareNetworkSecurityServiceFailure=(shareNetworkId,securityServiceId) ->
    type: app.DELETE_SHARE_NETWORK_SECURITY_SERVICE_FAILURE
    shareNetworkId: shareNetworkId
    securityServiceId: securityServiceId

  removeShareNetworkSecurityService=(shareNetworkId,securityServiceId) ->
    type: app.DELETE_SHARE_NETWORK_SECURITY_SERVICE_SUCCESS
    shareNetworkId: shareNetworkId
    securityServiceId: securityServiceId

  removeShareNetworkSecurityServices=(shareNetworkId) ->
    type: app.DELETE_SHARE_NETWORK_SECURITY_SERVICES_SUCCESS
    shareNetworkId: shareNetworkId

  requestShareNetworkSecurityServices= (shareNetworkId) ->
    type: app.REQUEST_SHARE_NETWORK_SECURITY_SERVICES
    shareNetworkId: shareNetworkId

  receiveShareNetworkSecurityServices= (shareNetworkId, json) ->
    type: app.RECEIVE_SHARE_NETWORK_SECURITY_SERVICES
    shareNetworkId: shareNetworkId
    securityServices: json
    receivedAt: Date.now()

  fetchShareNetworkSecurityServices= (shareNetworkId) ->
    (dispatch) ->
      dispatch(requestShareNetworkSecurityServices(shareNetworkId))
      app.ajaxHelper.get "/share-networks/#{shareNetworkId}/security-services",
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveShareNetworkSecurityServices(shareNetworkId,data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(app.showErrorDialog(title: 'Could not load share network security services', message:jqXHR.responseText))

  shouldFetchShareNetworkSecurityServices= (state, shareNetworkId) ->
    shareNetworkSecurityServices = state.shareNetworkSecurityServices[shareNetworkId]
    if !shareNetworkSecurityServices
      true
    else if shareNetworkSecurityServices.isFetching or shareNetworkSecurityServices.receivedAt
      false
    else
      false

  fetchShareNetworkSecurityServicesIfNeeded= (shareNetworkId) ->
    (dispatch, getState) ->
      dispatch(fetchShareNetworkSecurityServices(shareNetworkId)) if shouldFetchShareNetworkSecurityServices(getState(), shareNetworkId)

  deleteShareNetworkSecurityService= (shareNetworkId,securityServiceId) ->
    (dispatch) ->
      dispatch(requestDeleteShareNetworkSecurityService(shareNetworkId,securityServiceId))
      app.ajaxHelper.delete "/share-networks/#{shareNetworkId}/security-services/#{securityServiceId}",
        success: (data, textStatus, jqXHR) ->
          if data and data.errors
            dispatch(deleteShareNetworkSecurityServiceFailure(shareNetworkId,securityServiceId))
            dispatch(app.showErrorDialog(title: 'Could not remove security service from share network', message:jqXHR.responseText))
          else
            dispatch(removeShareNetworkSecurityService(shareNetworkId,securityServiceId))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(deleteShareNetworkSecurityServiceFailure(shareNetworkId,securityServiceId))
          dispatch(app.showErrorDialog(title: 'Could not remove security service from share network', message:jqXHR.responseText))

  ########################### SHARE RULE FORM #########################
  shareNetworkSecurityServiceFormForCreate=(shareNetworkId)->
    type: app.PREPARE_SHARE_NETWORK_SECURITY_SERVICE_FORM
    method: 'post'
    action: "/share-networks/#{shareNetworkId}/security-services"

  updateShareNetworkSecurityServiceForm= (name,value) ->
    type: app.UPDATE_SHARE_NETWORK_SECURITY_SERVICE_FORM
    name: name
    value: value

  resetShareNetworkSecurityServiceForm= () ->
    type: app.RESET_SHARE_NETWORK_SECURITY_SERVICE_FORM

  shareNetworkSecurityServiceFormFailure=(errors={}) ->
    type: app.SHARE_NETWORK_SECURITY_SERVICE_FORM_FAILURE
    errors: errors

  showShareNetworkSecurityServiceForm=() ->
    type: app.SHOW_SHARE_NETWORK_SECURITY_SERVICE_FORM

  hideShareNetworkSecurityServiceForm=()->
    type: app.HIDE_SHARE_NETWORK_SECURITY_SERVICE_FORM

  submitShareNetworkSecurityServiceForm= (shareNetworkId, successCallback=null) ->
    (dispatch, getState) ->
      shareNetworkSecurityServiceForm = getState().shareNetworkSecurityServiceForm
      if shareNetworkSecurityServiceForm.isValid
        dispatch(type: app.SUBMIT_SHARE_NETWORK_SECURITY_SERVICE_FORM)
        app.ajaxHelper[shareNetworkSecurityServiceForm.method] shareNetworkSecurityServiceForm.action,
          data: { security_service: shareNetworkSecurityServiceForm.data }
          success: (data, textStatus, jqXHR) ->
            if data.errors
              dispatch(shareNetworkSecurityServiceFormFailure(data.errors))
            else
              dispatch(receiveShareNetworkSecurityService(shareNetworkId, data))
              dispatch(resetShareNetworkSecurityServiceForm())
              dispatch(app.toggleShareNetworkIsNewStatus(shareNetworkId,false))
              successCallback() if successCallback
          error: ( jqXHR, textStatus, errorThrown) ->
            dispatch(shareNetworkSecurityServiceFormFailure({'internal error': ['Could not add security service to share network']}))
            dispatch(app.showErrorDialog(title: 'Could not add security service to share network', message:jqXHR.responseText))

  # export
  app.submitShareNetworkSecurityServiceForm         = submitShareNetworkSecurityServiceForm
  app.updateShareNetworkSecurityServiceForm         = updateShareNetworkSecurityServiceForm
  app.hideShareNetworkSecurityServiceForm           = hideShareNetworkSecurityServiceForm
  app.showShareNetworkSecurityServiceForm           = showShareNetworkSecurityServiceForm
  app.shareNetworkSecurityServiceFormForCreate      = shareNetworkSecurityServiceFormForCreate

  # export
  app.fetchShareNetworkSecurityServices              = fetchShareNetworkSecurityServices
  app.fetchShareNetworkSecurityServicesIfNeeded      = fetchShareNetworkSecurityServicesIfNeeded
  app.deleteShareNetworkSecurityService              = deleteShareNetworkSecurityService
  app.removeShareNetworkSecurityServices             = removeShareNetworkSecurityServices
  app.openShareNetworkSecurityServicesDialog         = openShareNetworkSecurityServicesDialog
)(shared_filesystem_storage)
