((app) ->
  #################### SNAPSHOTS #########################
  showSnapshotModal= (snapshot) ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'SHOW_SNAPSHOT',
    modalProps: {snapshot}

  newSnapshotModal= (share) ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'NEW_SNAPSHOT'
    modalProps: {share}

  editSnapshotModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'EDIT_SNAPSHOT'

  requestSnapshots= () ->
    type: app.REQUEST_SNAPSHOTS
    requestedAt: Date.now()

  requestSnapshotsFailure= () ->
    type: app.REQUEST_SNAPSHOTS_FAILURE

  receiveSnapshots= (json) ->
    type: app.RECEIVE_SNAPSHOTS
    snapshots: json
    receivedAt: Date.now()

  requestSnapshot= (snapshotId) ->
    type: app.REQUEST_SNAPSHOT
    snapshotId: snapshotId
    requestedAt: Date.now()

  requestSnapshotFailure= (snapshotId) ->
    type: app.REQUEST_SNAPSHOT_FAILURE
    snapshotId: snapshotId

  receiveSnapshot= (json) ->
    type: app.RECEIVE_SNAPSHOT
    snapshot: json

  fetchSnapshots= () ->
    (dispatch) ->
      dispatch(requestSnapshots())
      app.ajaxHelper.get '/snapshots',
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveSnapshots(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestSnapshotsFailure())
          dispatch(app.showErrorDialog(title: 'Could not load snapshots', message:jqXHR.responseText))

  shouldFetchSnapshots= (state) ->
    snapshots = state.snapshots
    if snapshots.isFetching or snapshots.requestedAt
      false
    else
      true

  fetchSnapshotsIfNeeded= () ->
    (dispatch, getState) ->
      dispatch(fetchSnapshots()) if shouldFetchSnapshots(getState())

  requestDelete=(snapshotId) ->
    type: app.REQUEST_DELETE_SNAPSHOT
    snapshotId: snapshotId

  deleteSnapshotFailure=(snapshotId) ->
    type: app.DELETE_SNAPSHOT_FAILURE
    snapshotId: snapshotId

  removeSnapshot=(snapshotId) ->
    type: app.DELETE_SNAPSHOT_SUCCESS
    snapshotId: snapshotId

  showDeleteSnapshotError=(snapshotId,message)->
    (dispatch)->
      dispatch(deleteSnapshotFailure(snapshotId))
      dispatch(app.showErrorDialog(title: 'Could not delete snapshot', message: message))

  deleteSnapshot= (snapshotId) ->
    (dispatch, getState) ->
      dispatch(requestDelete(snapshotId))
      app.ajaxHelper.delete "/snapshots/#{snapshotId}",
        success: (data, textStatus, jqXHR) ->
          if data and data.errors
            dispatch(showDeleteSnapshotError(snapshotId,ReactFormHelpers.Errors(data)))
          else
            dispatch(removeSnapshot(snapshotId))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(showDeleteSnapshotError(snapshotId,jqXHR.responseText))


  openDeleteSnapshotDialog=(snapshotId, options={}) ->
    (dispatch, getState) ->
      dispatch(app.showConfirmDialog({
        message: options.message || 'Do you really want to delete this snapshot?' ,
        confirmCallback: (() -> dispatch(deleteSnapshot(snapshotId)))
      }))

  openNewSnapshotDialog=(shareId)->
    (dispatch,getState) ->
      # find share
      for s in getState().shares.items
        if s.id == shareId
          share = s
          break
      dispatch(snapshotFormForCreate(share))
      dispatch(newSnapshotModal())

  openEditSnapshotDialog=(snapshot)->
    (dispatch) ->
      dispatch(snapshotFormForUpdate(snapshot))
      dispatch(editSnapshotModal())

  ################# SHARSNAPSHOTE FORM ###################
  resetSnapshotForm=()->
    type: app.RESET_SNAPSHOT_FORM

  snapshotFormForCreate=(share)->
    type: app.PREPARE_SNAPSHOT_FORM
    method: 'post'
    action: "/snapshots"
    data: {share_id: share.id, name: "#{share.name} snapshot"}

  snapshotFormForUpdate=(snapshot) ->
    type: app.PREPARE_SNAPSHOT_FORM
    data: snapshot
    method: 'put'
    action: "/snapshots/#{snapshot.id}"

  snapshotFormFailure=(errors) ->
    type: app.SNAPSHOT_FORM_FAILURE
    errors: errors

  updateSnapshotForm= (name,value) ->
    type: app.UPDATE_SNAPSHOT_FORM
    name: name
    value: value

  submitSnapshotForm= (successCallback=null) ->
    (dispatch, getState) ->
      snapshotForm = getState().snapshotForm
      if snapshotForm.isValid
        dispatch(type: app.SUBMIT_SNAPSHOT_FORM)
        app.ajaxHelper[snapshotForm.method] snapshotForm.action,
          data: { snapshot: snapshotForm.data }
          success: (data, textStatus, jqXHR) ->
            if data.errors
              dispatch(snapshotFormFailure(data.errors))
            else
              dispatch(receiveSnapshot(data))
              dispatch(resetSnapshotForm())
              successCallback() if successCallback
          error: ( jqXHR, textStatus, errorThrown) ->
            dispatch(app.showErrorDialog(title: 'Could not save snapshot', message:jqXHR.responseText))

  # export
  app.fetchSnapshots                 = fetchSnapshots
  app.fetchSnapshotsIfNeeded         = fetchSnapshotsIfNeeded
  app.deleteSnapshot                 = deleteSnapshot
  app.openNewSnapshotDialog          = openNewSnapshotDialog
  app.openDeleteSnapshotDialog       = openDeleteSnapshotDialog
  app.openEditSnapshotDialog         = openEditSnapshotDialog
  app.openShowSnapshotDialog         = showSnapshotModal

  app.snapshotFormForCreate          = snapshotFormForCreate
  app.snapshotFormForUpdate          = snapshotFormForUpdate
  app.submitSnapshotForm             = submitSnapshotForm
  app.updateSnapshotForm             = updateSnapshotForm
)(shared_filesystem_storage)
