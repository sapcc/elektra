((app) ->
  ########################### SECURITY_SERVICES ##############################
  initialSecurityServicesState =
    items: []
    receivedAt: null
    updatedAt: null
    isFetching: false

  requestSecurityServices=(state,{requestedAt})->
    ReactHelpers.mergeObjects({},state,{isFetching: true, requestedAt: requestedAt})

  requestSecurityServicesFailure=(state,{})->
    ReactHelpers.mergeObjects({},state,{isFetching: false})

  receiveSecurityServices=(state,{securityServices,receivedAt})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: securityServices
      receivedAt: receivedAt
    })

  requestSecurityService= (state,{securityServiceId,requestedAt}) ->
    index = ReactHelpers.findIndexInArray(state.items,securityServiceId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isFetching = true
    newState.items[index].requestedAt = requestedAt
    newState

  requestSecurityServiceFailure=(state,{securityServiceId})->
    index = ReactHelpers.findIndexInArray(state.items,securityServiceId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isFetching = false
    newState

  receiveSecurityService= (state,{securityService}) ->
    index = ReactHelpers.findIndexInArray(state.items,securityService.id)
    items = state.items.slice()
    # update or add
    if index>=0 then items[index]=securityService else items.push securityService
    ReactHelpers.mergeObjects({},state,{items})

  requestDeleteSecurityService= (state,{securityServiceId}) ->
    index = ReactHelpers.findIndexInArray(state.items,securityServiceId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isDeleting = true
    newState

  deleteSecurityServiceFailure= (state,{securityServiceId}) ->
    index = ReactHelpers.findIndexInArray(state.items,securityServiceId)
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].isDeleting = false
    newState

  deleteSecurityServiceSuccess= (state,{securityServiceId}) ->
    index = ReactHelpers.findIndexInArray(state.items,securityServiceId)
    return state if index<0
    items = state.items.slice()
    items.splice(index,1)
    ReactHelpers.mergeObjects({},state,{items})


  # securityServices reducer
  app.securityServices = (state = initialSecurityServicesState, action) ->
    switch action.type
      when app.RECEIVE_SECURITY_SERVICES then receiveSecurityServices(state,action)
      when app.REQUEST_SECURITY_SERVICES then requestSecurityServices(state,action)
      when app.REQUEST_SECURITY_SERVICES_FAILURE then requestSecurityServicesFailure(state,action)
      when app.REQUEST_SECURITY_SERVICE then requestSecurityService(state,action)
      when app.REQUEST_SECURITY_SERVICE_FAILURE then requestSecurityServiceFailure(state,action)
      when app.RECEIVE_SECURITY_SERVICE then receiveSecurityService(state,action)
      when app.REQUEST_DELETE_SECURITY_SERVICE then requestDeleteSecurityService(state,action)
      when app.DELETE_SECURITY_SERVICE_FAILURE then deleteSecurityServiceFailure(state,action)
      when app.DELETE_SECURITY_SERVICE_SUCCESS then deleteSecurityServiceSuccess(state,action)
      else state

)(shared_filesystem_storage)
