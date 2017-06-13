((app) ->

  requestShareNetworkSecurityServices=(state,{shareNetworkId})->
    newState = ReactHelpers.mergeObjects({},state)
    shareNetworkSecurityServices = newState[shareNetworkId] || {}

    newState[shareNetworkId] = ReactHelpers.mergeObjects({items: []},shareNetworkSecurityServices,{isFetching:true})
    newState

  receiveShareNetworkSecurityServices=(state,{shareNetworkId,receivedAt,securityServices})->
    newState = ReactHelpers.mergeObjects({},state)
    newState[shareNetworkId] =
      isFetching: false
      receivedAt: receivedAt
      items: securityServices
    newState

  receiveShareNetworkSecurityService=(state,{shareNetworkId,securityService})->
    # return old state unless shareNetworkSecurityServices entry exists
    unless state[shareNetworkId]
      return receiveShareNetworkSecurityServices(state,{shareNetworkId: shareNetworkId,shareNetworkSecurityServices: [securityService]})

    # copy current shareNetworkSecurityServices
    shareNetworkSecurityServices = ReactHelpers.mergeObjects({},state[shareNetworkId])
    shareNetworkSecurityServiceIndex = ReactHelpers.findIndexInArray(shareNetworkSecurityServices.items,securityService.id)
    if shareNetworkSecurityServiceIndex>=0
      shareNetworkSecurityServices.items[shareNetworkSecurityServiceIndex] = securityService
    else
      shareNetworkSecurityServices.items.push(securityService)

    # return new state (copy old state with new shareNetworkSecurityServices)
    ReactHelpers.mergeObjects({},state,{"#{shareNetworkId}": shareNetworkSecurityServices})


  requestDeleteShareNetworkSecurityService=(state,{shareNetworkId,securityServiceId})->
    # return old state unless shareNetworkSecurityServices entry exists
    return state unless (state[shareNetworkId] and state[shareNetworkId].items)
    shareNetworkSecurityServiceIndex = ReactHelpers.findIndexInArray(state[shareNetworkId].items,securityServiceId)
    return state if shareNetworkSecurityServiceIndex<0

    # copy current shareNetworkSecurityServices
    shareNetworkSecurityServices = ReactHelpers.mergeObjects({},state[shareNetworkId])
    # mark as deleting
    shareNetworkSecurityServices.items[shareNetworkSecurityServiceIndex].isDeleting=true
    # return new state (copy old state with new shareNetworkSecurityServices)
    ReactHelpers.mergeObjects({},state,{"#{shareNetworkId}": shareNetworkSecurityServices})

  deleteShareNetworkSecurityServiceFailure=(state,{shareNetworkId,securityServiceId})->
    # return old state unless shareNetworkSecurityServices entry exists
    return state unless (state[shareNetworkId] and state[shareNetworkId].items)
    shareNetworkSecurityServiceIndex = ReactHelpers.findIndexInArray(state[shareNetworkId].items,securityServiceId)
    return state if shareNetworkSecurityServiceIndex<0

    # copy current shareNetworkSecurityServices
    shareNetworkSecurityServices = ReactHelpers.mergeObjects({},state[shareNetworkId])
    # reset isDeleting flag
    shareNetworkSecurityServices.isDeleting=false
    # return new state (copy old state with new shareNetworkSecurityServices)
    ReactHelpers.mergeObjects({},state,{"#{shareNetworkId}": shareNetworkSecurityServices})

  deleteShareNetworkSecurityServiceSuccess=(state,{shareNetworkId,securityServiceId})->
    # return old state unless shareNetworkSecurityServices entry exists
    return state unless (state[shareNetworkId] and state[shareNetworkId].items)
    shareNetworkSecurityServiceIndex = ReactHelpers.findIndexInArray(state[shareNetworkId].items,securityServiceId)
    return state if shareNetworkSecurityServiceIndex<0

    # copy current shareNetworkSecurityServices
    shareNetworkSecurityServices = ReactHelpers.mergeObjects({},state[shareNetworkId])
    # delete shareNetworkSecurityService item
    shareNetworkSecurityServices.items.splice(shareNetworkSecurityServiceIndex,1)
    # return new state (copy old state with new shareNetworkSecurityServices)
    ReactHelpers.mergeObjects({},state,{"#{shareNetworkId}": shareNetworkSecurityServices})

  deleteShareNetworkSecurityServicesSuccess=(state,{shareNetworkId}) ->
    newState = ReactHelpers.mergeObjects({},state)
    delete newState[shareNetworkId]
    newState

  ######################### SHARE RULES #########################
  # {shareNetworkId: {items:Array, isFetching: Bool, receivedAt: Date} }

  initialShareNetworkSecurityServicesState = {}

  app.shareNetworkSecurityServices = (state = initialShareNetworkSecurityServicesState, action) ->
    switch action.type
      when app.RECEIVE_SHARE_NETWORK_SECURITY_SERVICES then receiveShareNetworkSecurityServices(state,action)
      when app.REQUEST_SHARE_NETWORK_SECURITY_SERVICES then requestShareNetworkSecurityServices(state,action)
      when app.RECEIVE_SHARE_NETWORK_SECURITY_SERVICE then receiveShareNetworkSecurityService(state,action)
      when app.REQUEST_DELETE_SHARE_NETWORK_SECURITY_SERVICE then requestDeleteShareNetworkSecurityService(state,action)
      when app.DELETE_SHARE_NETWORK_SECURITY_SERVICE_FAILURE then deleteShareNetworkSecurityServiceFailure(state,action)
      when app.DELETE_SHARE_NETWORK_SECURITY_SERVICE_SUCCESS then deleteShareNetworkSecurityServiceSuccess(state,action)
      when app.DELETE_SHARE_NETWORK_SECURITY_SERVICES_SUCCESS then deleteShareNetworkSecurityServicesSuccess(state,action)
      else state
)(shared_filesystem_storage)
