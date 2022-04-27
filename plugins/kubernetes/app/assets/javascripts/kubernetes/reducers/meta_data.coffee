((app) ->
  ########################## CLUSTER FORM ###########################
  initialMetaDataState =
    flavors: [
      {
        id: "m1.small"
        name: "m1.small"
      }
      {
        id: "m1.medium"
        name: "m1.medium"
      }
      {
        id: "m1.xmedium"
        name: "m1.xmedium"
      }
      {
        id: "m1.large"
        name: "m1.large"
      }
      {
        id: "m1.xlarge"
        name: "m1.xlarge"
      }
      {
        id: "m1.10xlarge"
        name: "m1.10xlarge"
      }
      {
        id: "x1.2xmemory"
        name: "x1.2xmemory"
      }
    ]
    availabilityZones: []
    loaded: false
    error: null
    isFetching: false


  requestMetaData = (state,{}) ->
    ReactHelpers.mergeObjects({},state,{
      isFetching: true
      error: null
    })

  requestMetaDataFailure = (state,{error})->
    oldErrorCount = state.errorCount || 0
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      error: error
      errorCount: oldErrorCount + 1
    })

  receiveMetaData = (state, {metaData}) ->
    metaData.availabilityZones.sort((a, b) => b.name.localeCompare(a.name))
    ReactHelpers.mergeObjects({},metaData,{
      isFetching: false
      error: null
      loaded: true
    })


  app.metaData = (state = initialMetaDataState, action) ->
    switch action.type
      when app.REQUEST_META_DATA           then requestMetaData(state,action)
      when app.REQUEST_META_DATA_FAILURE   then requestMetaDataFailure(state,action)
      when app.RECEIVE_META_DATA           then receiveMetaData(state,action)
      else state

)(kubernetes)
