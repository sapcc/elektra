((app) ->
  ########################## CLUSTER FORM ###########################
  initialClusterFormState =
    method: 'post'
    action: ''
    data: {
      name: ''
      spec: {
        nodePools: [
          {
            flavor: ''
            image: ''
            name: ''
            size: ''
          }
        ]
      }
    }
    isSubmitting: false
    errors: null
    isValid: false
    nodePoolsValid: false

  resetClusterForm = (action, {})->
    initialClusterFormState

  updateClusterForm = (state, {name, value})->
    data = ReactHelpers.mergeObjects({}, state.data, {"#{name}":value})
    ReactHelpers.mergeObjects({}, state, {
      data: data
      errors: null
      isSubmitting: false
      isValid: (data.name.length > 0 && state.nodePoolsValid)
    })

  updateNodePoolForm = (state, {index, name, value})->
    nodePool = ReactHelpers.mergeObjects({}, state.data.spec.nodePools[index], {"#{name}":value})
    nodePoolsClone = state.data.spec.nodePools.slice(0)
    if index>=0 then nodePoolsClone[index] = nodePool else nodePoolsClone.push nodePool
    data = ReactHelpers.mergeObjects({}, state.data, {spec: {nodePools: nodePoolsClone}})
    poolValidity = nodePool.name.length > 0 && nodePool.size >= 0 && nodePool.flavor.length > 0


    ReactHelpers.mergeObjects({}, state, {
      data: data
      errors: null
      isSubmitting: false
      nodePoolsValid: poolValidity
      isValid: (state.data.name.length > 0 && poolValidity)
    })

  addNodePool = (state, {}) ->
    newPool = {
                flavor: ''
                image: ''
                name: ''
                size: ''
                new: true
              }

    nodePoolsClone = state.data.spec.nodePools.slice(0)
    nodePoolsClone.push newPool
    data = ReactHelpers.mergeObjects({}, state.data, {spec: {nodePools: nodePoolsClone}})
    ReactHelpers.mergeObjects({}, state, {
      data: data
      errors: null
      isSubmitting: false
      isValid: true
    })

  deleteNodePool = (state, {index}) ->
    # remove pool with given index
    nodePoolsFiltered = state.data.spec.nodePools.filter((pool, i) -> parseInt(i,10) != parseInt(index, 10) )
    data = ReactHelpers.mergeObjects({}, state.data, {spec: {nodePools: nodePoolsFiltered}})

    ReactHelpers.mergeObjects({}, state, {
      data: data
      errors: null
      isSubmitting: false
      isValid: true
    })


  submitClusterForm = (state, {})->
    ReactHelpers.mergeObjects({}, state, {
      isSubmitting: true
      errors: null
    })

  prepareClusterForm = (state, {action, method, data})->
    values =
      method: method
      action: action
      errors: null
    values['data'] = data if data

    ReactHelpers.mergeObjects({}, initialClusterFormState,values)

  clusterFormFailure=(state, {errors})->
    ReactHelpers.mergeObjects({}, state, {
      isSubmitting: false
      errors: errors
    })

  app.clusterForm = (state = initialClusterFormState, action) ->
    switch action.type
      when app.RESET_CLUSTER_FORM     then resetClusterForm(state,action)
      when app.UPDATE_CLUSTER_FORM    then updateClusterForm(state,action)
      when app.UPDATE_NODE_POOL_FORM  then updateNodePoolForm(state,action)
      when app.ADD_NODE_POOL          then addNodePool(state,action)
      when app.DELETE_NODE_POOL       then deleteNodePool(state,action)
      when app.SUBMIT_CLUSTER_FORM    then submitClusterForm(state,action)
      when app.PREPARE_CLUSTER_FORM   then prepareClusterForm(state,action)
      when app.CLUSTER_FORM_FAILURE   then clusterFormFailure(state,action)
      else state

)(kubernetes)
