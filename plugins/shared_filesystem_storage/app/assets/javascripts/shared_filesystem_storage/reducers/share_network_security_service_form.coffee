((app) ->
  ########################## SHARE RULE FORM ###########################

  initialShareNetworkSecurityServiceFormState =
    method: 'post'
    data: {}
    isSubmitting: false
    errors: null
    isValid: false
    isHidden: true

  hideShareNetworkSecurityServiceForm=(state,{})->
    initialShareNetworkSecurityServiceFormState

  showShareNetworkSecurityServiceForm=(state,action)->
    ReactHelpers.mergeObjects({},state,{isHidden:false})

  prepareShareNetworkSecurityServiceForm=(state,{action,method})->
    ReactHelpers.mergeObjects({},initialShareNetworkSecurityServiceFormState,{
      action: action
      method: 'post'
    })

  updateShareNetworkSecurityServiceForm=(state,{name,value})->
    data = ReactHelpers.mergeObjects({},state.data,{"#{name}":value})
    ReactHelpers.mergeObjects({},state,{
      data:data
      errors: null
      isSubmitting: false
      isValid: (data.security_service_id)
    })

  submitShareNetworkSecurityServiceForm=(state,{})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: true
      errors: null
    })

  shareNetworkSecurityServiceFormFailure=(state,{errors})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: false
      errors: errors
    })

  app.shareNetworkSecurityServiceForm = (state = initialShareNetworkSecurityServiceFormState, action) ->
    switch action.type
      when app.HIDE_SHARE_NETWORK_SECURITY_SERVICE_FORM then hideShareNetworkSecurityServiceForm(state,action)
      when app.SHOW_SHARE_NETWORK_SECURITY_SERVICE_FORM then showShareNetworkSecurityServiceForm(state,action)
      when app.RESET_SHARE_NETWORK_SECURITY_SERVICE_FORM then hideShareNetworkSecurityServiceForm(state,action)
      when app.PREPARE_SHARE_NETWORK_SECURITY_SERVICE_FORM then prepareShareNetworkSecurityServiceForm(state,action)
      when app.UPDATE_SHARE_NETWORK_SECURITY_SERVICE_FORM then updateShareNetworkSecurityServiceForm(state,action)
      when app.SUBMIT_SHARE_NETWORK_SECURITY_SERVICE_FORM then submitShareNetworkSecurityServiceForm(state,action)
      when app.SHARE_NETWORK_SECURITY_SERVICE_FORM_FAILURE then shareNetworkSecurityServiceFormFailure(state,action)
      else state

)(shared_filesystem_storage)
