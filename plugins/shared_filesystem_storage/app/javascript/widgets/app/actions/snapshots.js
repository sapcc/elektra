import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice, addError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"

//################### SNAPSHOTS #########################
const requestSnapshots = () => ({
  type: constants.REQUEST_SNAPSHOTS,
  requestedAt: Date.now(),
})
const requestSnapshotsFailure = () => ({
  type: constants.REQUEST_SNAPSHOTS_FAILURE,
})

const receiveSnapshots = (json) => ({
  type: constants.RECEIVE_SNAPSHOTS,
  snapshots: json,
  receivedAt: Date.now(),
})
const requestSnapshot = (snapshotId) => ({
  type: constants.REQUEST_SNAPSHOT,
  snapshotId,
  requestedAt: Date.now(),
})
const requestSnapshotFailure = (snapshotId) => ({
  type: constants.REQUEST_SNAPSHOT_FAILURE,
  snapshotId,
})
const receiveSnapshot = (json) => ({
  type: constants.RECEIVE_SNAPSHOT,
  snapshot: json,
})
const canReloadSnapshot = function (state, snapshotId) {
  const { items } = state.snapshots
  const index = items.findIndex((i) => i.id === snapshotId)

  if (index < 0) {
    return true
  }
  return !items[index].isFetching
}

const reloadSnapshot = (snapshotId) =>
  function (dispatch, getState) {
    if (!canReloadSnapshot(getState(), snapshotId)) {
      return
    }

    dispatch(requestSnapshot(snapshotId))
    ajaxHelper
      .get(`/snapshots/${snapshotId}`)
      .then((response) => dispatch(receiveSnapshot(response.data)))
      .catch((error) => dispatch(requestSnapshotFailure()))
  }
const fetchSnapshots = () =>
  function (dispatch) {
    dispatch(requestSnapshots())
    return ajaxHelper
      .get("/snapshots")
      .then((response) => {
        dispatch(receiveSnapshots(response.data))
      })
      .catch((error) => {
        dispatch(requestSnapshotsFailure())
        addError(`Could not load snapshots (${error.message})`)
      })
  }
const shouldFetchSnapshots = function (state) {
  const { snapshots } = state
  if (!snapshots.isFetching && !snapshots.requestedAt) return true
  return false
}

const fetchSnapshotsIfNeeded = () =>
  function (dispatch, getState) {
    if (shouldFetchSnapshots(getState())) {
      return dispatch(fetchSnapshots())
    }
  }
const requestDelete = (snapshotId) => ({
  type: constants.REQUEST_DELETE_SNAPSHOT,
  snapshotId,
})
const deleteSnapshotFailure = (snapshotId) => ({
  type: constants.DELETE_SNAPSHOT_FAILURE,
  snapshotId,
})
const removeSnapshot = (snapshotId) => ({
  type: constants.DELETE_SNAPSHOT_SUCCESS,
  snapshotId,
})
const showDeleteSnapshotError = (snapshotId, message) =>
  function (dispatch) {
    dispatch(deleteSnapshotFailure(snapshotId))
    addError(`Could not delete snapshot (${message})`)
  }
const deleteSnapshot = (snapshotId) =>
  function (dispatch, getState) {
    confirm("Are you sure?")
      .then(() => {
        dispatch(requestDelete(snapshotId))
        ajaxHelper
          .delete(`/snapshots/${snapshotId}`)
          .then((response) => {
            if (response.data && response.data.errors) {
              addError(
                React.createElement(ErrorsList, {
                  errors: response.data.errors,
                })
              )
            } else dispatch(removeSnapshot(snapshotId))
          })
          .catch((error) =>
            addError(`Could not delete snapshot (${error.message})`)
          )
      })
      .catch((error) => null)
  }
//################ SHARSNAPSHOTE FORM ###################
const submitNewSnapshotForm = (values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .post("/snapshots", { snapshot: values })
      .then((response) => {
        if (response.data.errors) handleErrors({ errors: response.data.errors })
        else {
          dispatch(receiveSnapshot(response.data))
          handleSuccess()
          addNotice("Snapshot is being created.")
        }
      })
      .catch((error) => handleErrors({ errors: error.message }))
  })
const submitEditSnapshotForm = (values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) => {
    let snapshotId = values.id
    delete values["id"]

    ajaxHelper
      .put(`/snapshots/${snapshotId}`, { snapshot: values })
      .then((response) => {
        if (response.data.errors) handleErrors({ errors: response.data.errors })
        else {
          dispatch(receiveSnapshot(response.data))
          handleSuccess()
        }
      })
      .catch((error) => handleErrors({ errors: error.message }))
  })
// export
export {
  fetchSnapshotsIfNeeded,
  submitEditSnapshotForm,
  submitNewSnapshotForm,
  reloadSnapshot,
  deleteSnapshot,
}
