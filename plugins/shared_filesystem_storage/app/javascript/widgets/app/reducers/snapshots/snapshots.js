import * as constants from "../../constants"

//########################## SNAPSHOTS ##############################
const initialSnapshotsState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
}

const requestSnapshots = (state, { requestedAt }) =>
  Object.assign({}, state, { isFetching: true, requestedAt })

const requestSnapshotsFailure = function (state) {
  return ReactHelpers.mergeObjects({}, state, { isFetching: false })
}

const receiveSnapshots = (state, { snapshots, receivedAt }) =>
  Object.assign({}, state, {
    isFetching: false,
    items: snapshots,
    receivedAt,
  })
const requestSnapshot = function (state, { snapshotId, requestedAt }) {
  const index = state.items.findIndex((i) => i.id == snapshotId)
  if (index < 0) {
    return state
  }

  const newState = Object.assign({}, state)
  newState.items[index].isFetching = true
  newState.items[index].requestedAt = requestedAt
  return newState
}

const requestSnapshotFailure = function (state, { snapshotId }) {
  const index = state.items.findIndex((i) => i.id == snapshotId)
  if (index < 0) {
    return state
  }

  const newState = Object.assign({}, state)
  newState.items[index].isFetching = false
  return newState
}

const receiveSnapshot = function (state, { snapshot }) {
  const index = state.items.findIndex((i) => i.id == snapshot.id)
  const items = state.items.slice()
  // update or add
  if (index >= 0) {
    items[index] = snapshot
  } else {
    items.push(snapshot)
  }
  return Object.assign({}, state, { items })
}

const requestDeleteSnapshot = function (state, { snapshotId }) {
  const index = state.items.findIndex((item) => item.id == snapshotId)
  if (index < 0) {
    return state
  }

  const items = state.items.slice()
  items[index].isDeleting = true
  return Object.assign({}, state, { items })
}

const deleteSnapshotFailure = function (state, { snapshotId }) {
  const index = state.items.findIndex((i) => i.id == snapshotId)
  if (index < 0) {
    return state
  }

  const items = state.items.slice()
  items[index].isDeleting = false
  return Object.assign({}, state, { items })
}

const deleteSnapshotSuccess = function (state, { snapshotId }) {
  const index = state.items.findIndex((i) => i.id == snapshotId)
  if (index < 0) {
    return state
  }
  const items = state.items.slice()
  items.splice(index, 1)
  return Object.assign({}, state, { items })
}

// snapshots reducer
export const snapshots = function (state, action) {
  if (state == null) {
    state = initialSnapshotsState
  }
  switch (action.type) {
    case constants.RECEIVE_SNAPSHOTS:
      return receiveSnapshots(state, action)
    case constants.REQUEST_SNAPSHOTS:
      return requestSnapshots(state, action)
    case constants.REQUEST_SNAPSHOTS_FAILURE:
      return requestSnapshotsFailure(state, action)
    case constants.REQUEST_SNAPSHOT:
      return requestSnapshot(state, action)
    case constants.REQUEST_SNAPSHOT_FAILURE:
      return requestSnapshotFailure(state, action)
    case constants.RECEIVE_SNAPSHOT:
      return receiveSnapshot(state, action)
    case constants.REQUEST_DELETE_SNAPSHOT:
      return requestDeleteSnapshot(state, action)
    case constants.DELETE_SNAPSHOT_FAILURE:
      return deleteSnapshotFailure(state, action)
    case constants.DELETE_SNAPSHOT_SUCCESS:
      return deleteSnapshotSuccess(state, action)
    default:
      return state
  }
}
