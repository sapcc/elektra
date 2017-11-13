((app) ->

  requestSubnets=(state,{networkId})->
    newState = ReactHelpers.mergeObjects({},state)
    subnets = newState[networkId] || {}

    newState[networkId] = ReactHelpers.mergeObjects({},subnets,{isFetching:true})
    newState

  receiveSubnets=(state,{networkId,receivedAt,subnets})->
    newState = ReactHelpers.mergeObjects({},state)
    newState[networkId] =
      isFetching: false
      receivedAt: receivedAt
      items: subnets
    newState

  requestSubnetsFailure=(state,{})->
    newState = ReactHelpers.mergeObjects({},state)
    subnets = newState[networkId] || {}

    newState[networkId] = ReactHelpers.mergeObjects({},subnets,{isFetching:false})
    newState

  ######################### SUBNETS #########################
  # {networkId: {items:Array, isFetching: Bool, receivedAt: Date} }

  initialState = {}

  app.subnets = (state = initialState, action) ->
    switch action.type
      when app.RECEIVE_SUBNETS then receiveSubnets(state,action)
      when app.REQUEST_SUBNETS then requestSubnets(state,action)
      when app.REQUEST_SUBNETS_FAILURE then deleteSubnetsFailure(state,action)
      else state
)(shared_filesystem_storage)
