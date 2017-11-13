((app) ->
  ########################## SHARE FORM ###########################
  initialShareFormState =
    method: 'post'
    action: ''
    data: {}
    isSubmitting: false
    errors: null
    isValid: false

  resetShareForm=(action,{})->
    initialShareFormState

  updateShareForm=(state,{name,value})->
    data = ReactHelpers.mergeObjects({},state.data,{"#{name}":value})
    ReactHelpers.mergeObjects({},state,{
      data:data
      errors: null
      isSubmitting: false
      isValid: (data.share_proto && data.size && data.share_network_id)
    })

  submitShareForm=(state,{})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: true
      errors: null
    })

  prepareShareForm=(state,{action,method,data})->
    values =
      method: method
      action: action
      errors: null
    values['data']=data if data

    ReactHelpers.mergeObjects({},initialShareFormState,values)

  shareFormFailure=(state,{errors})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: false
      errors: errors
    })

  app.shareForm = (state = initialShareFormState, action) ->
    switch action.type
      when app.RESET_SHARE_FORM then resetShareForm(state,action)
      when app.UPDATE_SHARE_FORM then updateShareForm(state,action)
      when app.SUBMIT_SHARE_FORM then submitShareForm(state,action)
      when app.PREPARE_SHARE_FORM then prepareShareForm(state,action)
      when app.SHARE_FORM_FAILURE then shareFormFailure(state,action)
      else state

)(shared_filesystem_storage)
