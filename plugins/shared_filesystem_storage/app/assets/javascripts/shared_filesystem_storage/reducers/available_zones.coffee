((app) ->
  ########################### SHARES ##############################
  initialState =
    items: []
    receivedAt: null
    updatedAt: null
    isFetching: false

  requestAvailableZones=(state,{requestedAt})->
    ReactHelpers.mergeObjects({},state,{isFetching: true, requestedAt: requestedAt})

  requestAvailableZonesFailure=(state,{})->
    ReactHelpers.mergeObjects({},state,{isFetching: false})

  receiveAvailableZones=(state,{availabilityZones,receivedAt})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: availabilityZones
      receivedAt: receivedAt
    })

  # networks reducer
  app.availabilityZones = (state = initialState, action) ->
    switch action.type
      when app.RECEIVE_AVAILABLE_ZONES then receiveAvailableZones(state,action)
      when app.REQUEST_AVAILABLE_ZONES then requestAvailableZones(state,action)
      when app.REQUEST_AVAILABLE_ZONES_FAILURE then requestAvailableZonesFailure(state,action)
      else state

)(shared_filesystem_storage)
