((app) ->

  requestShareRules=(state,{shareId})->
    newState = ReactHelpers.mergeObjects({},state)
    rules = newState[shareId] || {}

    newState[shareId] = ReactHelpers.mergeObjects({},rules,{isFetching:true})
    newState

  receiveShareRules=(state,{shareId,receivedAt,rules})->
    newState = ReactHelpers.mergeObjects({},state)
    newState[shareId] =
      isFetching: false
      receivedAt: receivedAt
      items: rules
    newState

  receiveShareRule=(state,{shareId,rule})->
    # return old state unless rules entry exists
    return state unless state[shareId]

    # copy current rules
    rules = ReactHelpers.mergeObjects({},state[shareId])
    ruleIndex = ReactHelpers.findIndexInArray(rules.items,rule.id)
    if ruleIndex>=0
      rules.items[ruleIndex] = rule
    else
      rules.items.push(rule)

    # return new state (copy old state with new rules)
    ReactHelpers.mergeObjects({},state,{"#{shareId}": rules})


  requestDeleteShareRule=(state,{shareId,ruleId})->
    # return old state unless rules entry exists
    return state unless (state[shareId] and state[shareId].items)
    ruleIndex = ReactHelpers.findIndexInArray(state[shareId].items,ruleId)
    return state if ruleIndex<0

    # copy current rules
    rules = ReactHelpers.mergeObjects({},state[shareId])
    # mark as deleting
    rules.isDeleting=true
    # return new state (copy old state with new rules)
    ReactHelpers.mergeObjects({},state,{"#{shareId}": rules})

  deleteShareRuleFailure=(state,{shareId,ruleId})->
    # return old state unless rules entry exists
    return state unless (state[shareId] and state[shareId].items)
    ruleIndex = ReactHelpers.findIndexInArray(state[shareId].items,ruleId)
    return state if ruleIndex<0

    # copy current rules
    rules = ReactHelpers.mergeObjects({},state[shareId])
    # reset isDeleting flag
    rules.isDeleting=false
    # return new state (copy old state with new rules)
    ReactHelpers.mergeObjects({},state,{"#{shareId}": rules})

  deleteShareRuleSuccess=(state,{shareId,ruleId})->
    # return old state unless rules entry exists
    return state unless (state[shareId] and state[shareId].items)
    ruleIndex = ReactHelpers.findIndexInArray(state[shareId].items,ruleId)
    return state if ruleIndex<0

    # copy current rules
    rules = ReactHelpers.mergeObjects({},state[shareId])
    # delete rule item
    rules.items.splice(ruleIndex,1)
    # return new state (copy old state with new rules)
    ReactHelpers.mergeObjects({},state,{"#{shareId}": rules})



  ######################### SHARE RULES #########################
  # {shareId: {items:Array, isFetching: Bool, receivedAt: Date} }

  initialShareRulesState = {}

  app.shareRules = (state = initialShareRulesState, action) ->
    switch action.type
      when app.RECEIVE_SHARE_RULES then receiveShareRules(state,action)
      when app.REQUEST_SHARE_RULES then requestShareRules(state,action)
      when app.RECEIVE_SHARE_RULE then receiveShareRule(state,action)
      when app.REQUEST_DELETE_SHARE_RULE then requestDeleteShareRule(state,action)
      when app.DELETE_SHARE_RULE_FAILURE then deleteShareRuleFailure(state,action)
      when app.DELETE_SHARE_RULE_SUCCESS then deleteShareRuleSuccess(state,action)
      else state
)(shared_filesystem_storage)
