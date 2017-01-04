((app) ->
  ########################### SHARES ##############################
  initialState =
    items: []
    receivedAt: null
    updatedAt: null
    isFetching: false

  requestNetworks=(state,{requestedAt})->
    ReactHelpers.mergeObjects({},state,{isFetching: true, requestedAt: requestedAt})

  requestNetworksFailure=(state,{})->
    ReactHelpers.mergeObjects({},state,{isFetching: false})

  receiveNetworks=(state,{networks,receivedAt})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: networks
      receivedAt: receivedAt
    })

  # networks reducer
  app.networks = (state = initialState, action) ->
    switch action.type
      when app.RECEIVE_NETWORKS then receiveNetworks(state,action)
      when app.REQUEST_NETWORKS then requestNetworks(state,action)
      when app.REQUEST_NETWORKS_FAILURE then requestNetworksFailure(state,action)
      else state

)(shared_filesystem_storage)
