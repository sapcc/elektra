((app) ->
  ########################### SNAPSHOTS ##############################
  initialSnapshotsState =
    items: []
    receivedAt: null
    updatedAt: null
    isFetching: false

  requestSnapshots=(state,{requestedAt})->
    ReactHelpers.mergeObjects({},state,{isFetching: true,requestedAt: requestedAt})

  requestSnapshotsFailure=(state,{})->
    ReactHelpers.mergeObjects({},state,{isFetching: false})

  receiveSnapshots=(state,{snapshots,receivedAt})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: snapshots
      receivedAt: receivedAt
    })

  requestSnapshot= (state,{snapshotId,requestedAt}) ->
    index = ReactHelpers.findIndexInArray(state.items,snapshotId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isFetching = true
    newState.items[index].requestedAt = requestedAt
    newState

  requestSnapshotFailure=(state,{snapshotId})->
    index = ReactHelpers.findIndexInArray(state.items,snapshotId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isFetching = false
    newState

  receiveSnapshot= (state,{snapshot}) ->
    index = ReactHelpers.findIndexInArray(state.items,snapshot.id)
    items = state.items.slice()
    # update or add
    if index>=0 then items[index]=snapshot else items.push snapshot
    ReactHelpers.mergeObjects({},state,{items: items})

  requestDeleteSnapshot= (state,{snapshotId}) ->
    index = ReactHelpers.findIndexInArray(state.items,snapshotId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isDeleting = true
    newState

  deleteSnapshotFailure= (state,{snapshotId}) ->
    index = ReactHelpers.findIndexInArray(state.items,snapshotId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isDeleting = false
    newState

  deleteSnapshotSuccess= (state,{snapshotId}) ->
    index = ReactHelpers.findIndexInArray(state.items,snapshotId)
    return state if index<0
    items = state.items.slice()
    items.splice(index,1)
    ReactHelpers.mergeObjects({},state,{items:items})

  # snapshots reducer
  app.snapshots = (state = initialSnapshotsState, action) ->
    switch action.type
      when app.RECEIVE_SNAPSHOTS then receiveSnapshots(state,action)
      when app.REQUEST_SNAPSHOTS then requestSnapshots(state,action)
      when app.REQUEST_SNAPSHOTS_FAILURE then requestSnapshotsFailure(state,action)
      when app.REQUEST_SNAPSHOT then requestSnapshot(state,action)
      when app.REQUEST_SNAPSHOT_FAILURE then requestSnapshotFailure(state,action)
      when app.RECEIVE_SNAPSHOT then receiveSnapshot(state,action)
      when app.REQUEST_DELETE_SNAPSHOT then requestDeleteSnapshot(state,action)
      when app.DELETE_SNAPSHOT_FAILURE then deleteSnapshotFailure(state,action)
      when app.DELETE_SNAPSHOT_SUCCESS then deleteSnapshotSuccess(state,action)
      else state

)(shared_filesystem_storage)
