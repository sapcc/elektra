import * as constants from "../../constants"

//########################## REPLICAS ##############################
const initialReplicasState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
}

const requestReplicas = (state, { requestedAt }) => ({
  ...state,
  isFetching: true,
  requestedAt,
})

const requestReplicasFailure = (state) => ({ ...state, isFetching: false })

const receiveReplicas = (state, { replicas, receivedAt }) => ({
  ...state,
  isFetching: false,
  items: replicas,
  receivedAt,
})

const requestReplica = function (state, { replicaId, requestedAt }) {
  const index = state.items.findIndex((i) => i.id == replicaId)
  if (index < 0) {
    return state
  }

  const newState = Object.assign({}, state)
  newState.items[index].isFetching = true
  newState.items[index].requestedAt = requestedAt
  return newState
}

const requestReplicaFailure = function (state, { replicaId }) {
  const index = state.items.findIndex((i) => i.id == replicaId)
  if (index < 0) {
    return state
  }

  const newState = Object.assign({}, state)
  newState.items[index].isFetching = false
  return newState
}

const receiveReplica = function (state, { replica }) {
  const index = state.items.findIndex((i) => i.id == replica.id)
  const items = state.items.slice()
  // update or add
  if (index >= 0) {
    items[index] = replica
  } else {
    items.push(replica)
  }
  return Object.assign({}, state, { items })
}

const requestDeleteReplica = function (state, { replicaId }) {
  const index = state.items.findIndex((item) => item.id == replicaId)
  if (index < 0) {
    return state
  }

  const items = state.items.slice()
  items[index].isDeleting = true
  return Object.assign({}, state, { items })
}

const deleteReplicaFailure = function (state, { replicaId }) {
  const index = state.items.findIndex((i) => i.id == replicaId)
  if (index < 0) {
    return state
  }

  const items = state.items.slice()
  items[index].isDeleting = false
  return Object.assign({}, state, { items })
}

const deleteReplicaSuccess = function (state, { replicaId }) {
  const index = state.items.findIndex((i) => i.id == replicaId)
  if (index < 0) {
    return state
  }
  const items = state.items.slice()
  items.splice(index, 1)
  return Object.assign({}, state, { items })
}

// replicas reducer
export const replicas = function (state, action) {
  if (state == null) {
    state = initialReplicasState
  }
  switch (action.type) {
    case constants.RECEIVE_REPLICAS:
      return receiveReplicas(state, action)
    case constants.REQUEST_REPLICAS:
      return requestReplicas(state, action)
    case constants.REQUEST_REPLICAS_FAILURE:
      return requestReplicasFailure(state, action)
    case constants.REQUEST_REPLICA:
      return requestReplica(state, action)
    case constants.REQUEST_REPLICA_FAILURE:
      return requestReplicaFailure(state, action)
    case constants.RECEIVE_REPLICA:
      return receiveReplica(state, action)
    case constants.REQUEST_DELETE_REPLICA:
      return requestDeleteReplica(state, action)
    case constants.DELETE_REPLICA_FAILURE:
      return deleteReplicaFailure(state, action)
    case constants.DELETE_REPLICA_SUCCESS:
      return deleteReplicaSuccess(state, action)
    default:
      return state
  }
}
