((app) ->
  ########################## SHARE RULE FORM ###########################

  initialShareRuleFormState =
    method: 'post'
    shareId: null
    data: {}
    isSubmitting: false
    errors: null
    isValid: false
    isHidden: true

  hideSahreRuleForm=(state,{})->
    initialShareRuleFormState

  showShareRuleForm=(state,action)->
    ReactHelpers.mergeObjects({},state,{isHidden:false})

  prepareShareRuleForm=(state,{action,method})->
    ReactHelpers.mergeObjects({},initialShareRuleFormState,{
      action: action
      method: 'post'
    })

  updateShareRuleForm=(state,{name,value})->
    data = ReactHelpers.mergeObjects({},state.data,{"#{name}":value})
    ReactHelpers.mergeObjects({},state,{
      data:data
      errors: null
      isSubmitting: false
      isValid: (data.access_type && data.access_level && data.access_to)
    })

  submitShareRuleForm=(state,{})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: true
      errors: null
    })

  shareRuleFormFailure=(state,{errors})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: false
      errors: errors
    })

  app.shareRuleForm = (state = initialShareRuleFormState, action) ->
    switch action.type
      when app.HIDE_SHARE_RULE_FORM then hideSahreRuleForm(state,action)
      when app.SHOW_SHARE_RULE_FORM then showShareRuleForm(state,action)
      when app.RESET_SHARE_RULE_FORM then hideSahreRuleForm(state,action)
      when app.PREPARE_SHARE_RULE_FORM then prepareShareRuleForm(state,action)
      when app.UPDATE_SHARE_RULE_FORM then updateShareRuleForm(state,action)
      when app.SUBMIT_SHARE_RULE_FORM then submitShareRuleForm(state,action)
      when app.SHARE_RULE_FORM_FAILURE then shareRuleFormFailure(state,action)
      else state

)(shared_filesystem_storage)
