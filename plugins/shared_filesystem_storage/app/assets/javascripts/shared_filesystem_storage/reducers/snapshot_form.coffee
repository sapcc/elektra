((app) ->
  ########################## SNAPSHOT FORM ###########################
  initialSnapshotFormState =
    method: 'post'
    action: ''
    data: {}
    isSubmitting: false
    errors: null
    isValid: false

  resetSnapshotForm=(action,{})->
    initialSnapshotFormState

  updateSnapshotForm=(state,{name,value})->
    data = ReactHelpers.mergeObjects({},state.data,{"#{name}":value})
    ReactHelpers.mergeObjects({},state,{
      data:data
      errors: null
      isSubmitting: false
      isValid: (data.share_id)
    })

  submitSnapshotForm=(state,{})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: true
      errors: null
    })

  prepareSnapshotForm=(state,{action,method,data})->
    values =
      method: method
      action: action
      errors: null

    if data
      values['data']=data
      values['isValid'] = data.share_id

    ReactHelpers.mergeObjects({},initialSnapshotFormState,values)

  snapshotFormFailure=(state,{errors})->
    ReactHelpers.mergeObjects({},state,{
      isSubmitting: false
      errors: errors
    })

  app.snapshotForm = (state = initialSnapshotFormState, action) ->
    switch action.type
      when app.RESET_SNAPSHOT_FORM then resetSnapshotForm(state,action)
      when app.UPDATE_SNAPSHOT_FORM then updateSnapshotForm(state,action)
      when app.SUBMIT_SNAPSHOT_FORM then submitSnapshotForm(state,action)
      when app.PREPARE_SNAPSHOT_FORM then prepareSnapshotForm(state,action)
      when app.SNAPSHOT_FORM_FAILURE then snapshotFormFailure(state,action)
      else state

)(shared_filesystem_storage)
