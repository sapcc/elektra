((app) ->
  ########################## CLUSTER FORM ###########################
  initialClusterFormState =
    method: 'post'
    action: ''
    data: {}
    isSubmitting: false
    errors: null
    isValid: false

  resetClusterForm = (action, {})->
    initialClusterFormState

  updateClusterForm = (state, {name, value})->
    data = ReactHelpers.mergeObjects({}, state.data, {"#{name}":value})
    ReactHelpers.mergeObjects({}, state, {
      data: data
      errors: null
      isSubmitting: false
      isValid: (data.name?)
    })

  submitClusterForm = (state, {})->
    ReactHelpers.mergeObjects({}, state, {
      isSubmitting: true
      errors: null
    })

  prepareClusterForm = (state, {action, method, data})->
    values =
      method: method
      action: action
      errors: null
    values['data'] = data if data

    ReactHelpers.mergeObjects({}, initialClusterFormState,values)

  clusterFormFailure=(state, {errors})->
    ReactHelpers.mergeObjects({}, state, {
      isSubmitting: false
      errors: errors
    })

  app.clusterForm = (state = initialClusterFormState, action) ->
    switch action.type
      when app.RESET_CLUSTER_FORM   then resetClusterForm(state,action)
      when app.UPDATE_CLUSTER_FORM  then updateClusterForm(state,action)
      when app.SUBMIT_CLUSTER_FORM  then submitClusterForm(state,action)
      when app.PREPARE_CLUSTER_FORM then prepareClusterForm(state,action)
      when app.CLUSTER_FORM_FAILURE then clusterFormFailure(state,action)
      else state

)(kubernetes)
