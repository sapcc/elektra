((app) ->
  #################### SECURITY_SERVICES #########################
  showSecurityServiceModal= (securitServiceId) ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'SHOW_SECURITY_SERVICE',
    modalProps: {securitServiceId}

  newSecurityServiceModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'NEW_SECURITY_SERVICE'

  editSecurityServiceModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'EDIT_SECURITY_SERVICE'

  requestSecurityServices= () ->
    type: app.REQUEST_SECURITY_SERVICES
    requestedAt: Date.now()

  requestSecurityServicesFailure= () ->
    type: app.REQUEST_SECURITY_SERVICES_FAILURE

  receiveSecurityServices= (json) ->
    type: app.RECEIVE_SECURITY_SERVICES
    securityServices: json
    receivedAt: Date.now()

  requestSecurityService= (securityServiceId) ->
    type: app.REQUEST_SECURITY_SERVICE
    securityServiceId: securityServiceId
    requestedAt: Date.now()

  requestSecurityServiceFailure= (securityServiceId) ->
    type: app.REQUEST_SECURITY_SERVICE_FAILURE
    securityServiceId: securityServiceId

  receiveSecurityService= (json) ->
    type: app.RECEIVE_SECURITY_SERVICE
    securityService: json

  fetchSecurityServices= () ->
    (dispatch) ->
      dispatch(requestSecurityServices())
      app.ajaxHelper.get '/security_services',
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveSecurityServices(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestSecurityServicesFailure())
          dispatch(app.showErrorDialog(title: 'Could not load security services', message:jqXHR.responseText))

  shouldFetchSecurityServices= (state) ->
    securityServices = state.securityServices
    if securityServices.isFetching or securityServices.requestedAt
      false
    else
      true

  fetchSecurityServicesIfNeeded= () ->
    (dispatch, getState) ->
      dispatch(fetchSecurityServices()) if shouldFetchSecurityServices(getState())

  canReloadSecurityService= (state,securityServiceId) ->
    items = state.securityServices.items
    index = -1
    for item,i in items
      if item.id==securityServiceId
        index = i
        break
    return true if index<0
    return not items[index].isFetching

  reloadSecurityService= (securityServiceId) ->
    (dispatch,getState) ->
      return unless canReloadSecurityService(getState(),securityServiceId)

      dispatch(requestSecurityService(securityServiceId))
      app.ajaxHelper.get "/security_services/#{securityServiceId}",
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveSecurityService(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestSecurityServiceFailure())
          dispatch(app.showErrorDialog(title: 'Could not reload security service', message:jqXHR.responseText))

  requestDelete=(securityServiceId) ->
    type: app.REQUEST_DELETE_SECURITY_SERVICE
    securityServiceId: securityServiceId

  deleteSecurityServiceFailure=(securityServiceId) ->
    type: app.DELETE_SECURITY_SERVICE_FAILURE
    securityServiceId: securityServiceId

  removeSecurityService=(securityServiceId) ->
    type: app.DELETE_SECURITY_SERVICE_SUCCESS
    securityServiceId: securityServiceId

  showDeleteSecurityServiceDialog=(securityServiceId,message)->
    (dispatch)->
      dispatch(deleteSecurityServiceFailure(securityServiceId))
      dispatch(app.showErrorDialog(title: 'Could not delete security service', message: message))

  deleteSecurityService= (securityServiceId) ->
    (dispatch, getState) ->
      dispatch(requestDelete(securityServiceId))
      app.ajaxHelper.delete "/security_services/#{securityServiceId}",
        success: (data, textStatus, jqXHR) ->
          if data and data.errors
            dispatch(showDeleteSecurityServiceDialog(securityServiceId, ReactFormHelpers.Errors(data)))
          else
            dispatch(removeSecurityService(securityServiceId))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(showDeleteSecurityServiceDialog(securityServiceId,jqXHR.responseText))

  openDeleteSecurityServiceDialog=(securityServiceId, options={}) ->
    (dispatch, getState) ->
      dependentSecurityServiceNetworks = []
      # check if there are dependent securityService networks.
      # Problem: the securityService networks may not be loaded yet
      securityServiceNetworks = getState().securityServiceNetworks
      if securityServiceNetworks and securityServiceNetworks.items
        for securityServiceNetwork in securityServiceNetworks.items
          dependentSecurityServiceNetworks.push(securityServiceNetwork) if false

      if dependentSecurityServiceNetworks.length==0
        dispatch(app.showConfirmDialog({
          message: options.message || 'Do you really want to delete this security service?' ,
          confirmCallback: (() -> dispatch(deleteSecurityService(securityServiceId)))
        }))
      else
        dispatch(app.showInfoDialog(title: 'Existing Dependencies', message: "Please remove thi security service from securityService networks (#{dependentSecurityServiceNetworks.length}) first!"))

  openNewSecurityServiceDialog=()->
    (dispatch) ->
      dispatch(securityServiceFormForCreate())
      dispatch(newSecurityServiceModal())

  openEditSecurityServiceDialog=(securityService)->
    (dispatch) ->
      dispatch(securityServiceFormForUpdate(securityService))
      dispatch(editSecurityServiceModal())

  ################# SECURITY_SERVICE FORM ###################
  resetSecurityServiceForm=()->
    type: app.RESET_SECURITY_SERVICE_FORM

  securityServiceFormForCreate=()->
    type: app.PREPARE_SECURITY_SERVICE_FORM
    method: 'post'
    action: "/security_services"

  securityServiceFormForUpdate=(securityService) ->
    type: app.PREPARE_SECURITY_SERVICE_FORM
    data: securityService
    method: 'put'
    action: "/security_services/#{securityService.id}"

  securityServiceFormFailure=(errors) ->
    type: app.SECURITY_SERVICE_FORM_FAILURE
    errors: errors

  updateSecurityServiceForm= (name,value) ->
    type: app.UPDATE_SECURITY_SERVICE_FORM
    name: name
    value: value

  submitSecurityServiceForm= (successCallback=null) ->
    (dispatch, getState) ->
      securityServiceForm = getState().securityServiceForm
      if securityServiceForm.isValid
        dispatch(type: app.SUBMIT_SECURITY_SERVICE_FORM)
        app.ajaxHelper[securityServiceForm.method] securityServiceForm.action,
          data: { securityService: securityServiceForm.data }
          success: (data, textStatus, jqXHR) ->
            if data.errors
              dispatch(securityServiceFormFailure(data.errors))
            else
              dispatch(receiveSecurityService(data))
              dispatch(resetSecurityServiceForm())
              successCallback() if successCallback
          error: ( jqXHR, textStatus, errorThrown) ->
            dispatch(app.showErrorDialog(title: 'Could not save security service', message:jqXHR.responseText))

  # export
  app.fetchSecurityServices                 = fetchSecurityServices
  app.fetchSecurityServicesIfNeeded         = fetchSecurityServicesIfNeeded
  app.reloadSecurityService                 = reloadSecurityService
  app.deleteSecurityService                 = deleteSecurityService
  app.openNewSecurityServiceDialog          = openNewSecurityServiceDialog
  app.openDeleteSecurityServiceDialog       = openDeleteSecurityServiceDialog
  app.openEditSecurityServiceDialog         = openEditSecurityServiceDialog
  app.openShowSecurityServiceDialog         = showSecurityServiceModal

  app.securityServiceFormForCreate          = securityServiceFormForCreate
  app.securityServiceFormForUpdate          = securityServiceFormForUpdate
  app.submitSecurityServiceForm             = submitSecurityServiceForm
  app.updateSecurityServiceForm             = updateSecurityServiceForm
)(shared_filesystem_storage)
