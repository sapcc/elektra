((app) ->
  #################### SHARES #########################
  showShareModal= (shareId) ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'SHOW_SHARE',
    modalProps: {shareId}

  newShareModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'NEW_SHARE'

  editShareModal= () ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'EDIT_SHARE'

  requestShares= () ->
    type: app.REQUEST_SHARES
    requestedAt: Date.now()

  requestSharesFailure= () ->
    type: app.REQUEST_SHARES_FAILURE

  receiveShares= (json) ->
    type: app.RECEIVE_SHARES
    shares: json
    receivedAt: Date.now()

  requestShare= (shareId) ->
    type: app.REQUEST_SHARE
    shareId: shareId
    requestedAt: Date.now()

  requestShareFailure= (shareId) ->
    type: app.REQUEST_SHARE_FAILURE
    shareId: shareId

  receiveShare= (json) ->
    type: app.RECEIVE_SHARE
    share: json

  fetchShares= () ->
    (dispatch) ->
      dispatch(requestShares())
      app.ajaxHelper.get '/shares',
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveShares(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestSharesFailure())
          dispatch(app.showErrorDialog(title: 'Could not load shares', message:jqXHR.responseText))

  shouldFetchShares= (state) ->
    shares = state.shares
    if shares.isFetching or shares.requestedAt
      false
    else
      true

  fetchSharesIfNeeded= () ->
    (dispatch, getState) ->
      dispatch(fetchShares()) if shouldFetchShares(getState())

  canReloadShare= (state,shareId) ->
    items = state.shares.items
    index = -1
    for item,i in items
      if item.id==shareId
        index = i
        break
    return true if index<0
    return not items[index].isFetching

  reloadShare= (shareId) ->
    (dispatch,getState) ->
      return unless canReloadShare(getState(),shareId)

      dispatch(requestShare(shareId))
      app.ajaxHelper.get "/shares/#{shareId}",
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveShare(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestShareFailure())
          dispatch(app.showErrorDialog(title: 'Could not reload share', message:jqXHR.responseText))

  requestDelete=(shareId) ->
    type: app.REQUEST_DELETE_SHARE
    shareId: shareId

  deleteShareFailure=(shareId) ->
    type: app.DELETE_SHARE_FAILURE
    shareId: shareId

  removeShare=(shareId) ->
    type: app.DELETE_SHARE_SUCCESS
    shareId: shareId

  showDeleteShareDialog=(shareId,message)->
    (dispatch)->
      dispatch(deleteShareFailure(shareId))
      dispatch(app.showErrorDialog(title: 'Could not delete share', message: message))

  deleteShare= (shareId) ->
    (dispatch, getState) ->
      dispatch(requestDelete(shareId))
      app.ajaxHelper.delete "/shares/#{shareId}",
        success: (data, textStatus, jqXHR) ->
          if data and data.errors
            dispatch(showDeleteShareDialog(shareId, ReactFormHelpers.Errors(data)))
          else
            dispatch(removeShare(shareId))
            dispatch(app.removeShareRules(shareId))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(showDeleteShareDialog(shareId,jqXHR.responseText))

  openDeleteShareDialog=(shareId, options={}) ->
    (dispatch, getState) ->
      shareSnapshots = []
      # check if there are dependent snapshots.
      # Problem: the snapshots may not be loaded yet
      snapshots = getState().snapshots
      if snapshots and snapshots.items
        for snapshot in snapshots.items
          shareSnapshots.push(snapshot) if snapshot.share_id==shareId

      if shareSnapshots.length==0
        dispatch(app.showConfirmDialog({
          message: options.message || 'Do you really want to delete this share?' ,
          confirmCallback: (() -> dispatch(deleteShare(shareId)))
        }))
      else
        dispatch(app.showInfoDialog(title: 'Existing Dependencies', message: "Please delete dependent snapshots(#{shareSnapshots.length}) first!"))

  openNewShareDialog=()->
    (dispatch) ->
      dispatch(shareFormForCreate())
      dispatch(newShareModal())

  openEditShareDialog=(share)->
    (dispatch) ->
      dispatch(shareFormForUpdate(share))
      dispatch(editShareModal())

  ################ SHARE EXPORT LOCATIONS ################
  requestShareExportLocations= (shareId) ->
    type: app.REQUEST_SHARE_EXPORT_LOCATIONS
    shareId: shareId

  receiveShareExportLocations= (shareId, json) ->
    type: app.RECEIVE_SHARE_EXPORT_LOCATIONS
    shareId: shareId
    export_locations: json
    receivedAt: Date.now()

  fetchShareExportLocations= (shareId) ->
    (dispatch) ->
      dispatch(requestShareExportLocations(shareId))
      app.ajaxHelper.get "/shares/#{shareId}/export_locations",
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveShareExportLocations(shareId,data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(app.showErrorDialog(title: 'Could not load share export locations', message:jqXHR.responseText))

  ################# SHARE FORM ###################
  resetShareForm=()->
    type: app.RESET_SHARE_FORM

  shareFormForCreate=()->
    type: app.PREPARE_SHARE_FORM
    method: 'post'
    action: "/shares"

  shareFormForUpdate=(share) ->
    type: app.PREPARE_SHARE_FORM
    data: share
    method: 'put'
    action: "/shares/#{share.id}"

  shareFormFailure=(errors) ->
    type: app.SHARE_FORM_FAILURE
    errors: errors

  updateShareForm= (name,value) ->
    type: app.UPDATE_SHARE_FORM
    name: name
    value: value

  submitShareForm= (successCallback=null) ->
    (dispatch, getState) ->
      shareForm = getState().shareForm
      if shareForm.isValid
        dispatch(type: app.SUBMIT_SHARE_FORM)
        app.ajaxHelper[shareForm.method] shareForm.action,
          data: { share: shareForm.data }
          success: (data, textStatus, jqXHR) ->
            if data.errors
              dispatch(shareFormFailure(data.errors))
            else
              dispatch(receiveShare(data))
              dispatch(resetShareForm())
              successCallback() if successCallback
          error: ( jqXHR, textStatus, errorThrown) ->
            dispatch(app.showErrorDialog(title: 'Could not save share', message:jqXHR.responseText))

  ######################## AVAILABILITY ZONES ###########################
  # Manila availability zones, not nova!!!
  shouldFetchAvailabilityZones= (state) ->
    azs = state.availabilityZones
    if azs.isFetching
      false
    else if azs.receivedAt
      false
    else
      true
  requestAvailableZones= () ->
    type: app.REQUEST_AVAILABLE_ZONES

  requestAvailableZonesFailure= () ->
    type: app.REQUEST_AVAILABLE_ZONES_FAILURE

  receiveAvailableZones= (json) ->
    type: app.RECEIVE_AVAILABLE_ZONES
    availabilityZones: json
    receivedAt: Date.now()

  fetchAvailabilityZones=() ->
    (dispatch) ->
      dispatch(requestAvailableZones())
      app.ajaxHelper.get '/shares/availability_zones',
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveAvailableZones(data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestAvailableZonesFailure())

  fetchAvailabilityZonesIfNeeded= () ->
    (dispatch, getState) ->
      dispatch(fetchAvailabilityZones()) if shouldFetchAvailabilityZones(getState())

  # export
  app.fetchShares                 = fetchShares
  app.fetchSharesIfNeeded         = fetchSharesIfNeeded
  app.reloadShare                 = reloadShare
  app.deleteShare                 = deleteShare
  app.openNewShareDialog          = openNewShareDialog
  app.openDeleteShareDialog       = openDeleteShareDialog
  app.openEditShareDialog         = openEditShareDialog
  app.openShowShareDialog         = showShareModal
  app.fetchShareExportLocations   = fetchShareExportLocations

  app.shareFormForCreate          = shareFormForCreate
  app.shareFormForUpdate          = shareFormForUpdate
  app.submitShareForm             = submitShareForm
  app.updateShareForm             = updateShareForm

  app.fetchAvailabilityZonesIfNeeded = fetchAvailabilityZonesIfNeeded
)(shared_filesystem_storage)
