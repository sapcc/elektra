((app) ->
  ########################## SECURITY_SERVICE FORM ###########################
  initialSecurityServiceFormState =
    method: 'post'
    action: ''
    data: {}
    isSubmitting: false
    errors: null
    isValid: false

  resetSecurityServiceForm=(action,{})->
    initialSecurityServiceFormState

  updateSecurityServiceForm=(state,{name,value})->
    data = ReactHelpers.mergeObjects({},state.data,{"#{name}":value})
    ReactHelpers.mergeObjects({},state,{
      data:data
      errors: null
      isSubmitting: false
      isValid: (data.type && data.name)
    })

  submitSecurityServiceForm=(state,{})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: true
      errors: null
    })

  prepareSecurityServiceForm=(state,{action,method,data})->
    values =
      method: method
      action: action
      errors: null
    values['data']=data if data

    ReactHelpers.mergeObjects({},initialSecurityServiceFormState,values)

  securityServiceFormFailure=(state,{errors})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: false
      errors: errors
    })

  app.securityServiceForm = (state = initialSecurityServiceFormState, action) ->
    switch action.type
      when app.RESET_SECURITY_SERVICE_FORM then resetSecurityServiceForm(state,action)
      when app.UPDATE_SECURITY_SERVICE_FORM then updateSecurityServiceForm(state,action)
      when app.SUBMIT_SECURITY_SERVICE_FORM then submitSecurityServiceForm(state,action)
      when app.PREPARE_SECURITY_SERVICE_FORM then prepareSecurityServiceForm(state,action)
      when app.SECURITY_SERVICE_FORM_FAILURE then securityServiceFormFailure(state,action)
      else state

)(shared_filesystem_storage)
