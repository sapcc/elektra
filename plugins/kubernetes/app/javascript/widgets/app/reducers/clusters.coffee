import * as constants from "../constants"

########################### CLUSTERS ##############################
initialKubernikusState =
  error: null
  flashError: null
  total: 0
  items: []
  isFetching: false
  events: {}


# ----- list ------
requestClusters = (state,{}) ->
  ReactHelpers.mergeObjects({},state,{
    isFetching: true
  })

requestClustersFailure = (state,{error})->
  ReactHelpers.mergeObjects({},state,{
    isFetching: false
    error: error
  })

receiveClusters = (state,{clusters})->
  ReactHelpers.mergeObjects({},state,{
    isFetching: false
    items: clusters
    error: null
  })

# ----- item ------
requestCluster = (state,{}) ->
  state # TODO: set isFetching on item

requestClusterFailure = (state,{error})->
  state # TODO: set isFetching on item


receiveCluster = (state, {cluster}) ->
  index = ReactHelpers.findIndexInArray(state.items,cluster.name, 'name')
  items = state.items.slice() # clone array
  # update or add
  if index>=0 then items[index]=cluster else items.push cluster
  ReactHelpers.mergeObjects({},state,{items})


deleteCluster = (state,{clusterName}) ->
  # ReactHelpers.mergeObjects({},state,{
  #   deleteTarget: clusterName
  # })
  index = ReactHelpers.findIndexInArray(state.items,clusterName, 'name')
  return state if index < 0
  items = state.items.slice(0) # clone array
  items[index].isTerminating = true
  ReactHelpers.mergeObjects({},state,{items})

deleteClusterFailure = (state,{clusterName, error})->
  ReactHelpers.mergeObjects({},state,{
    deleteTarget: ''
    error: error
  })

requestCredentials = (state,{}) ->
  state

requestCredentialsFailure = (state,{clusterName, flashError})->
  ReactHelpers.mergeObjects({},state,{
    flashError: flashError
  })

requestSetupInfo = (state,{}) ->
  state

requestSetupInfoFailure = (state,{clusterName, flashError})->
  ReactHelpers.mergeObjects({},state,{
    flashError: flashError
  })

dataForSetupInfo = (state, {setupData, kubernikusBaseUrl}) ->
  ReactHelpers.mergeObjects({}, state, {
    setupData: setupData
    kubernikusBaseUrl: kubernikusBaseUrl
  })

startPollingCluster = (state, {clusterName}) ->
  index = ReactHelpers.findIndexInArray(state.items,clusterName, 'name')
  return state if index < 0
  items = state.items.slice(0) # clone array
  items[index].isPolling = true
  ReactHelpers.mergeObjects({},state,{items})

stopPollingCluster = (state, {clusterName}) ->
  index = ReactHelpers.findIndexInArray(state.items,clusterName, 'name')
  return state if index < 0
  items = state.items.slice(0) # clone array
  items[index].isPolling = false
  ReactHelpers.mergeObjects({},state,{items})


# --------- cluster events -------------------
requestClusterEvents = (state,{}) ->
  state # TODO: set isFetching on item

requestClusterEventsFailure = (state,{error})->
  state # TODO: set isFetching on item

receiveClusterEvents = (state, {clusterName, events}) ->
  # index = ReactHelpers.findIndexInArray(state.events, clusterName, 'name')
  # items = state.items.slice() # clone array
  # # update or add
  # if index>=0 then items[index]["events"] = events
  # ReactHelpers.mergeObjects({},state,{items})
  allEvents = JSON.parse(JSON.stringify(state.events))
  allEvents[clusterName] = events.reverse()
  ReactHelpers.mergeObjects({},state,{events: allEvents})



# clusters reducer
clusters = (state = initialKubernikusState, action) ->
  switch action.type
    when constants.REQUEST_CLUSTERS                 then requestClusters(state,action)
    when constants.REQUEST_CLUSTERS_FAILURE         then requestClustersFailure(state,action)
    when constants.RECEIVE_CLUSTERS                 then receiveClusters(state,action)
    when constants.REQUEST_CLUSTER                  then requestCluster(state,action)
    when constants.REQUEST_CLUSTER_FAILURE          then requestClusterFailure(state,action)
    when constants.RECEIVE_CLUSTER                  then receiveCluster(state,action)
    when constants.DELETE_CLUSTER                   then deleteCluster(state,action)
    when constants.START_POLLING_CLUSTER            then startPollingCluster(state,action)
    when constants.STOP_POLLING_CLUSTER             then stopPollingCluster(state,action)
    when constants.DELETE_CLUSTER_FAILURE           then deleteClusterFailure(state,action)
    when constants.REQUEST_CLUSTER_EVENTS           then requestClusterEvents(state,action)
    when constants.REQUEST_CLUSTER_EVENTS_FAILURE   then requestClusterEventsFailure(state,action)
    when constants.RECEIVE_CLUSTER_EVENTS           then receiveClusterEvents(state,action)
    when constants.REQUEST_CREDENTIALS              then requestCredentials(state,action)
    when constants.REQUEST_CREDENTIALS_FAILURE      then requestCredentialsFailure(state,action)
    when constants.REQUEST_SETUP_INFO               then requestSetupInfo(state,action)
    when constants.REQUEST_SETUP_INFO_FAILURE       then requestSetupInfoFailure(state,action)
    when constants.SETUP_INFO_DATA                  then dataForSetupInfo(state,action)
    else state

export default clusters
