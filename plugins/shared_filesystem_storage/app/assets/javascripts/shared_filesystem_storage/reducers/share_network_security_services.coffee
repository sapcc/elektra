((app) ->

  requestShareNetworkSecurityServices=(state,{shareNetworkId})->
    newState = ReactHelpers.mergeObjects({},state)
    shareNetworkSecurityServices = newState[shareNetworkId] || {}

    newState[shareNetworkId] = ReactHelpers.mergeObjects({},shareNetworkSecurityServices,{isFetching:true})
    newState

  receiveShareNetworkSecurityServices=(state,{shareNetworkId,receivedAt,shareNetworkSecurityServices})->
    newState = ReactHelpers.mergeObjects({},state)
    newState[shareNetworkId] =
      isFetching: false
      receivedAt: receivedAt
      items: shareNetworkSecurityServices
    newState

  receiveShareNetworkSecurityService=(state,{shareNetworkId,shareNetworkSecurityService})->
    # return old state unless shareNetworkSecurityServices entry exists
    unless state[shareNetworkId]
      return receiveShareNetworkSecurityServices(state,{shareNetworkId: shareNetworkId,shareNetworkSecurityServices: [shareNetworkSecurityService]})

    # copy current shareNetworkSecurityServices
    shareNetworkSecurityServices = ReactHelpers.mergeObjects({},state[shareNetworkId])
    shareNetworkSecurityServiceIndex = ReactHelpers.findIndexInArray(shareNetworkSecurityServices.items,shareNetworkSecurityService.id)
    if shareNetworkSecurityServiceIndex>=0
      shareNetworkSecurityServices.items[shareNetworkSecurityServiceIndex] = shareNetworkSecurityService
    else
      shareNetworkSecurityServices.items.push(shareNetworkSecurityService)

    # return new state (copy old state with new shareNetworkSecurityServices)
    ReactHelpers.mergeObjects({},state,{"#{shareNetworkId}": shareNetworkSecurityServices})


  requestDeleteShareNetworkSecurityService=(state,{shareNetworkId,shareNetworkSecurityServiceId})->
    # return old state unless shareNetworkSecurityServices entry exists
    return state unless (state[shareNetworkId] and state[shareNetworkId].items)
    shareNetworkSecurityServiceIndex = ReactHelpers.findIndexInArray(state[shareNetworkId].items,shareNetworkSecurityServiceId)
    return state if shareNetworkSecurityServiceIndex<0

    # copy current shareNetworkSecurityServices
    shareNetworkSecurityServices = ReactHelpers.mergeObjects({},state[shareNetworkId])
    # mark as deleting
    shareNetworkSecurityServices.isDeleting=true
    # return new state (copy old state with new shareNetworkSecurityServices)
    ReactHelpers.mergeObjects({},state,{"#{shareNetworkId}": shareNetworkSecurityServices})

  deleteShareNetworkSecurityServiceFailure=(state,{shareNetworkId,shareNetworkSecurityServiceId})->
    # return old state unless shareNetworkSecurityServices entry exists
    return state unless (state[shareNetworkId] and state[shareNetworkId].items)
    shareNetworkSecurityServiceIndex = ReactHelpers.findIndexInArray(state[shareNetworkId].items,shareNetworkSecurityServiceId)
    return state if shareNetworkSecurityServiceIndex<0

    # copy current shareNetworkSecurityServices
    shareNetworkSecurityServices = ReactHelpers.mergeObjects({},state[shareNetworkId])
    # reset isDeleting flag
    shareNetworkSecurityServices.isDeleting=false
    # return new state (copy old state with new shareNetworkSecurityServices)
    ReactHelpers.mergeObjects({},state,{"#{shareNetworkId}": shareNetworkSecurityServices})

  deleteShareNetworkSecurityServiceSuccess=(state,{shareNetworkId,shareNetworkSecurityServiceId})->
    # return old state unless shareNetworkSecurityServices entry exists
    return state unless (state[shareNetworkId] and state[shareNetworkId].items)
    shareNetworkSecurityServiceIndex = ReactHelpers.findIndexInArray(state[shareNetworkId].items,shareNetworkSecurityServiceId)
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
      when app.RECEIVE_SHARE_RULES then receiveShareNetworkSecurityServices(state,action)
      when app.REQUEST_SHARE_RULES then requestShareNetworkSecurityServices(state,action)
      when app.RECEIVE_SHARE_RULE then receiveShareNetworkSecurityService(state,action)
      when app.REQUEST_DELETE_SHARE_RULE then requestDeleteShareNetworkSecurityService(state,action)
      when app.DELETE_SHARE_RULE_FAILURE then deleteShareNetworkSecurityServiceFailure(state,action)
      when app.DELETE_SHARE_RULE_SUCCESS then deleteShareNetworkSecurityServiceSuccess(state,action)
      when app.DELETE_SHARE_RULES_SUCCESS then deleteShareNetworkSecurityServicesSuccess(state,action)
      else state
)(shared_filesystem_storage)
