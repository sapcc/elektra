((app) ->
  ########################## SHARE_NETWORK FORM ###########################
  initialShareNetworkFormState =
    method: 'post'
    action: ''
    data: {}
    isSubmitting: false
    errors: null
    isValid: false

  resetShareNetworkForm=(action,{})->
    initialShareNetworkFormState

  updateShareNetworkForm=(state,{name,value})->
    data = ReactHelpers.mergeObjects({},state.data,{"#{name}":value})
    ReactHelpers.mergeObjects({},state,{
      data:data
      errors: null
      isSubmitting: false
      isValid: (data.name && data.neutron_net_id && data.neutron_subnet_id)
    })

  submitShareNetworkForm=(state,{})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: true
      errors: null
    })

  prepareShareNetworkForm=(state,{action,method,data})->
    values =
      method: method
      action: action
      errors: null
    values['data']=data if data

    ReactHelpers.mergeObjects({},initialShareNetworkFormState,values)

  shareNetworkFormFailure=(state,{errors})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: false
      errors: errors
    })

  app.shareNetworkForm = (state = initialShareNetworkFormState, action) ->
    switch action.type
      when app.RESET_SHARE_NETWORK_FORM then resetShareNetworkForm(state,action)
      when app.UPDATE_SHARE_NETWORK_FORM then updateShareNetworkForm(state,action)
      when app.SUBMIT_SHARE_NETWORK_FORM then submitShareNetworkForm(state,action)
      when app.PREPARE_SHARE_NETWORK_FORM then prepareShareNetworkForm(state,action)
      when app.SHARE_NETWORK_FORM_FAILURE then shareNetworkFormFailure(state,action)
      else state

)(shared_filesystem_storage)
