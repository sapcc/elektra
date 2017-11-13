((app) ->
  ########################### SHARES ##############################
  initialSharesState =
    items: []
    receivedAt: null
    updatedAt: null
    isFetching: false

  requestShares=(state,{requestedAt})->
    ReactHelpers.mergeObjects({},state,{isFetching: true, requestedAt: requestedAt})

  requestSharesFailure=(state,{})->
    ReactHelpers.mergeObjects({},state,{isFetching: false})

  receiveShares=(state,{shares,receivedAt})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: shares
      receivedAt: receivedAt
    })

  requestShare= (state,{shareId,requestedAt}) ->
    index = ReactHelpers.findIndexInArray(state.items,shareId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isFetching = true
    newState.items[index].requestedAt = requestedAt
    newState

  requestShareFailure=(state,{shareId})->
    index = ReactHelpers.findIndexInArray(state.items,shareId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isFetching = false
    newState

  receiveShare= (state,{share}) ->
    index = ReactHelpers.findIndexInArray(state.items,share.id)
    items = state.items.slice()
    # update or add
    if index>=0 then items[index]=share else items.push share
    ReactHelpers.mergeObjects({},state,{items})

  requestDeleteShare= (state,{shareId}) ->
    index = ReactHelpers.findIndexInArray(state.items,shareId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isDeleting = true
    newState

  deleteShareFailure= (state,{shareId}) ->
    index = ReactHelpers.findIndexInArray(state.items,shareId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isDeleting = false
    newState

  deleteShareSuccess= (state,{shareId}) ->
    index = ReactHelpers.findIndexInArray(state.items,shareId)
    return state if index<0
    items = state.items.slice()
    items.splice(index,1)
    ReactHelpers.mergeObjects({},state,{items})

  receiveShareExportLocations= (state,{shareId,export_locations})->
    index = ReactHelpers.findIndexInArray(state.items,shareId)
    return state if index<0
    items = state.items.slice()
    items[index].export_locations = export_locations
    ReactHelpers.mergeObjects({},state,{items})

  # shares reducer
  app.shares = (state = initialSharesState, action) ->
    switch action.type
      when app.RECEIVE_SHARES then receiveShares(state,action)
      when app.REQUEST_SHARES then requestShares(state,action)
      when app.REQUEST_SHARES_FAILURE then requestSharesFailure(state,action)
      when app.REQUEST_SHARE then requestShare(state,action)
      when app.REQUEST_SHARE_FAILURE then requestShareFailure(state,action)
      when app.RECEIVE_SHARE then receiveShare(state,action)
      when app.REQUEST_DELETE_SHARE then requestDeleteShare(state,action)
      when app.DELETE_SHARE_FAILURE then deleteShareFailure(state,action)
      when app.DELETE_SHARE_SUCCESS then deleteShareSuccess(state,action)
      when app.REQUEST_SHARE_EXPORT_LOCATIONS then state
      when app.RECEIVE_SHARE_EXPORT_LOCATIONS then receiveShareExportLocations(state,action)

      else state

)(shared_filesystem_storage)
