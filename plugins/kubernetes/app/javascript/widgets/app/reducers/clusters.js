/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import ReactHelpers from "../lib/helpers"
import * as constants from "../constants"

//########################## CLUSTERS ##############################
const initialKubernikusState = {
  error: null,
  flashError: null,
  total: 0,
  items: [],
  isFetching: false,
  events: {},
}

// ----- list ------
const requestClusters = function (state, ...rest) {
  const obj = rest[0]
  return ReactHelpers.mergeObjects({}, state, {
    isFetching: true,
  })
}

const requestClustersFailure = (state, { error }) =>
  ReactHelpers.mergeObjects({}, state, {
    isFetching: false,
    error,
  })

const receiveClusters = (state, { clusters }) =>
  ReactHelpers.mergeObjects({}, state, {
    isFetching: false,
    items: clusters,
    error: null,
  })

// ----- item ------
const requestCluster = function (state, ...rest) {
  const obj = rest[0]
  return state // TODO: set isFetching on item
}

const requestClusterFailure = (state, { error }) => state

const receiveCluster = function (state, { cluster }) {
  const index = ReactHelpers.findIndexInArray(state.items, cluster.name, "name")
  const items = state.items.slice() // clone array
  // update or add
  if (index >= 0) {
    items[index] = cluster
  } else {
    items.push(cluster)
  }
  return ReactHelpers.mergeObjects({}, state, { items })
}

const deleteCluster = function (state, { clusterName }) {
  // ReactHelpers.mergeObjects({},state,{
  //   deleteTarget: clusterName
  // })
  const index = ReactHelpers.findIndexInArray(state.items, clusterName, "name")
  if (index < 0) {
    return state
  }
  const items = state.items.slice(0) // clone array
  items[index].isTerminating = true
  return ReactHelpers.mergeObjects({}, state, { items })
}

const deleteClusterFailure = (state, { clusterName, error }) =>
  ReactHelpers.mergeObjects({}, state, {
    deleteTarget: "",
    error,
  })

const requestCredentials = function (state, ...rest) {
  const obj = rest[0]
  return state
}

const requestCredentialsFailure = (state, { clusterName, flashError }) =>
  ReactHelpers.mergeObjects({}, state, {
    flashError,
  })

const requestSetupInfo = function (state, ...rest) {
  const obj = rest[0]
  return state
}

const requestSetupInfoFailure = (state, { clusterName, flashError }) =>
  ReactHelpers.mergeObjects({}, state, {
    flashError,
  })

const dataForSetupInfo = (state, { setupData, kubernikusBaseUrl }) =>
  ReactHelpers.mergeObjects({}, state, {
    setupData,
    kubernikusBaseUrl,
  })

const startPollingCluster = function (state, { clusterName }) {
  const index = ReactHelpers.findIndexInArray(state.items, clusterName, "name")
  if (index < 0) {
    return state
  }
  const items = state.items.slice(0) // clone array
  items[index].isPolling = true
  return ReactHelpers.mergeObjects({}, state, { items })
}

const stopPollingCluster = function (state, { clusterName }) {
  const index = ReactHelpers.findIndexInArray(state.items, clusterName, "name")
  if (index < 0) {
    return state
  }
  const items = state.items.slice(0) // clone array
  items[index].isPolling = false
  return ReactHelpers.mergeObjects({}, state, { items })
}

// --------- cluster events -------------------
const requestClusterEvents = function (state, ...rest) {
  const obj = rest[0]
  return state // TODO: set isFetching on item
}

const requestClusterEventsFailure = (state, { error }) => state

const receiveClusterEvents = function (state, { clusterName, events }) {
  // index = ReactHelpers.findIndexInArray(state.events, clusterName, 'name')
  // items = state.items.slice() # clone array
  // # update or add
  // if index>=0 then items[index]["events"] = events
  // ReactHelpers.mergeObjects({},state,{items})
  const allEvents = JSON.parse(JSON.stringify(state.events))
  allEvents[clusterName] = events.reverse()
  return ReactHelpers.mergeObjects({}, state, { events: allEvents })
}

// clusters reducer
const clusters = function (state, action) {
  if (state == null) {
    state = initialKubernikusState
  }
  switch (action.type) {
    case constants.REQUEST_CLUSTERS:
      return requestClusters(state, action)
    case constants.REQUEST_CLUSTERS_FAILURE:
      return requestClustersFailure(state, action)
    case constants.RECEIVE_CLUSTERS:
      return receiveClusters(state, action)
    case constants.REQUEST_CLUSTER:
      return requestCluster(state, action)
    case constants.REQUEST_CLUSTER_FAILURE:
      return requestClusterFailure(state, action)
    case constants.RECEIVE_CLUSTER:
      return receiveCluster(state, action)
    case constants.DELETE_CLUSTER:
      return deleteCluster(state, action)
    case constants.START_POLLING_CLUSTER:
      return startPollingCluster(state, action)
    case constants.STOP_POLLING_CLUSTER:
      return stopPollingCluster(state, action)
    case constants.DELETE_CLUSTER_FAILURE:
      return deleteClusterFailure(state, action)
    case constants.REQUEST_CLUSTER_EVENTS:
      return requestClusterEvents(state, action)
    case constants.REQUEST_CLUSTER_EVENTS_FAILURE:
      return requestClusterEventsFailure(state, action)
    case constants.RECEIVE_CLUSTER_EVENTS:
      return receiveClusterEvents(state, action)
    case constants.REQUEST_CREDENTIALS:
      return requestCredentials(state, action)
    case constants.REQUEST_CREDENTIALS_FAILURE:
      return requestCredentialsFailure(state, action)
    case constants.REQUEST_SETUP_INFO:
      return requestSetupInfo(state, action)
    case constants.REQUEST_SETUP_INFO_FAILURE:
      return requestSetupInfoFailure(state, action)
    case constants.SETUP_INFO_DATA:
      return dataForSetupInfo(state, action)
    default:
      return state
  }
}

export default clusters
