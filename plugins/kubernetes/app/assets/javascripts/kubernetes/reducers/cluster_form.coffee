((app) ->
  ########################## CLUSTER FORM ###########################
  initialClusterFormState =
    method: 'post'
    action: ''
    data: {
      name: ''
      spec: {
        nodepools: [
          {
            flavor: ''
            image: ''
            name: ''
            size: null
          }
        ]
      }
    }
    isSubmitting: false
    errors: null
    isValid: false

  resetClusterForm = (action, {})->
    initialClusterFormState

  updateClusterForm = (state, {name, value})->
    data = ReactHelpers.mergeObjects({}, state.data, {"#{name}":value})
    ReactHelpers.mergeObjects({}, state, {
      data: data
      errors: null
      isSubmitting: false
      isValid: (data.name?)
    })

  updateNodePoolForm = (state, {index, name, value})->
    console.log("Index: #{index} -- Name: #{name} -- Value: #{value}")
    nodePool = ReactHelpers.mergeObjects({}, state.data.spec.nodepools[index], {"#{name}":value})
    console.log("Nodepool old vs new: ", state.data.spec.nodepools[index], nodePool)
    nodePoolsClone = state.data.spec.nodepools.slice(0)
    if index>=0 then nodePoolsClone[index] = nodePool else nodePoolsClone.push nodePool
    console.log("Nodepools: ", nodePoolsClone)
    data = ReactHelpers.mergeObjects({}, state.data, {spec: {nodepools: nodePoolsClone}})
    console.log("Data: ", data)

    ReactHelpers.mergeObjects({}, state, {
      data: data
      errors: null
      isSubmitting: false
      isValid: true #TODO: more fancy validity check
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
      when app.SUBMIT_CLUSTER_FORM    then submitClusterForm(state,action)
      when app.PREPARE_CLUSTER_FORM   then prepareClusterForm(state,action)
      when app.CLUSTER_FORM_FAILURE   then clusterFormFailure(state,action)
      else state

)(kubernetes)
