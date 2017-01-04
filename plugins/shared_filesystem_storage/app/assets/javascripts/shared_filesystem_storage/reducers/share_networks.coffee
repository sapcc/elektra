((app) ->
  ########################### SHARE_NETWORKS ##############################
  initialShareNetworksState =
    items: []
    receivedAt: null
    updatedAt: null
    isFetching: false

  requestShareNetworks=(state,{})->
    ReactHelpers.mergeObjects({},state,{isFetching: true})

  requestShareNetworksFailure=(state,{})->
    ReactHelpers.mergeObjects({},state,{isFetching: false})

  receiveShareNetworks=(state,{shareNetworks})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: shareNetworks
    })

  requestShareNetwork= (state,{shareNetworkId}) ->
    index = ReactHelpers.findIndexInArray(state.items,shareNetworkId)
    return state if index<0

    items = state.items.slice()
    items[index].isFetching = true
    ReactHelpers.mergeObjects({},state,{items})

  requestShareNetworkFailure=(state,{shareNetworkId})->
    index = ReactHelpers.findIndexInArray(state.items,shareNetworkId)
    return state if index<0

    items = state.items.slice()
    items[index].isFetching = false
    ReactHelpers.mergeObjects({},state,{items})

  receiveShareNetwork= (state,{shareNetwork}) ->
    index = ReactHelpers.findIndexInArray(state.items,shareNetwork.id)
    items = state.items.slice()
    # update or add
    if index>=0 then items[index]=shareNetwork else items.push shareNetwork
    ReactHelpers.mergeObjects({},state,{items})

  requestDeleteShareNetwork= (state,{shareNetworkId}) ->
    index = ReactHelpers.findIndexInArray(state.items,shareNetworkId)
    return state if index<0

    items = state.items.slice()
    items[index].isDeleting = true
    ReactHelpers.mergeObjects({},state,{items: items})

  deleteShareNetworkFailure= (state,{shareNetworkId}) ->
    index = ReactHelpers.findIndexInArray(state.items,shareNetworkId)
    return state if index<0
    items = state.items.slice()
    items[index].isDeleting=false
    ReactHelpers.mergeObjects({},state,{items})

  deleteShareNetworkSuccess= (state,{shareNetworkId}) ->
    index = ReactHelpers.findIndexInArray(state.items,shareNetworkId)
    return state if index<0
    items = state.items.slice()
    items.splice(index,1)
    ReactHelpers.mergeObjects({},state,{items})

  # shareNetworks reducer
  app.shareNetworks = (state = initialShareNetworksState, action) ->
    switch action.type
      when app.RECEIVE_SHARE_NETWORKS then receiveShareNetworks(state,action)
      when app.REQUEST_SHARE_NETWORKS then requestShareNetworks(state,action)
      when app.REQUEST_SHARE_NETWORKS_FAILURE then requestShareNetworksFailure(state,action)
      when app.REQUEST_SHARE_NETWORK then requestShareNetwork(state,action)
      when app.REQUEST_SHARE_NETWORK_FAILURE then requestShareNetworkFailure(state,action)
      when app.RECEIVE_SHARE_NETWORK then receiveShareNetwork(state,action)
      when app.REQUEST_DELETE_SHARE_NETWORK then requestDeleteShareNetwork(state,action)
      when app.DELETE_SHARE_NETWORK_FAILURE then deleteShareNetworkFailure(state,action)
      when app.DELETE_SHARE_NETWORK_SUCCESS then deleteShareNetworkSuccess(state,action)
      else state

)(shared_filesystem_storage)
