import * as constants from "../constants"
import { ajaxHelper } from "ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice, addError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"

//################### REPLICAS #########################
const requestReplicas = () => ({
  type: constants.REQUEST_REPLICAS,
  requestedAt: Date.now(),
})
const requestReplicasFailure = () => ({
  type: constants.REQUEST_REPLICAS_FAILURE,
})

const resetFetchingState = (replicaId) => ({
  type: constants.RESET_REPLICA_FETCHING_STATE,
  replicaId,
})

const receiveReplicas = (json) => ({
  type: constants.RECEIVE_REPLICAS,
  replicas: json || [],
  receivedAt: Date.now(),
})
const requestReplica = (replicaId) => ({
  type: constants.REQUEST_REPLICA,
  replicaId,
  requestedAt: Date.now(),
})
const requestReplicaFailure = (replicaId) => ({
  type: constants.REQUEST_REPLICA_FAILURE,
  replicaId,
})
const receiveReplica = (json) => ({
  type: constants.RECEIVE_REPLICA,
  replica: json,
})
const canReloadReplica = function (state, replicaId) {
  const { items } = state.replicas
  const index = items.findIndex((i) => i.id === replicaId)

  if (index < 0) {
    return true
  }
  return !items[index].isFetching
}

const reloadReplica = (replicaId) =>
  function (dispatch, getState) {
    if (!canReloadReplica(getState(), replicaId)) {
      return
    }

    dispatch(requestReplica(replicaId))
    ajaxHelper
      .get(`/replicas/${replicaId}`)
      .then((response) => dispatch(receiveReplica(response.data)))
      .catch((error) => dispatch(requestReplicaFailure()))
  }
const fetchReplicas = () =>
  function (dispatch) {
    dispatch(requestReplicas())
    return ajaxHelper
      .get("/replicas")
      .then((response) => {
        dispatch(receiveReplicas(response.data))
      })
      .catch((error) => {
        dispatch(requestReplicasFailure())
        addError(`Could not load replicas (${error.message})`)
      })
  }
const shouldFetchReplicas = function (state) {
  const { replicas } = state
  if (!replicas.isFetching && !replicas.requestedAt) return true
  return false
}

const fetchReplicasIfNeeded = () =>
  function (dispatch, getState) {
    if (shouldFetchReplicas(getState())) {
      return dispatch(fetchReplicas())
    }
  }
const requestDelete = (replicaId) => ({
  type: constants.REQUEST_DELETE_REPLICA,
  replicaId,
})
const deleteReplicaFailure = (replicaId) => ({
  type: constants.DELETE_REPLICA_FAILURE,
  replicaId,
})
const removeReplica = (replicaId) => ({
  type: constants.DELETE_REPLICA_SUCCESS,
  replicaId,
})
const deleteReplica = (replicaId) =>
  function (dispatch, getState) {
    confirm("Are you sure?")
      .then(() => {
        dispatch(requestDelete(replicaId))
        ajaxHelper
          .delete(`/replicas/${replicaId}`)
          .then((response) => {
            if (response.data && response.data.errors) {
              addError(
                React.createElement(ErrorsList, {
                  errors: response.data.errors,
                })
              )
              dispatch(deleteReplicaFailure(replicaId))
            } else dispatch(removeReplica(replicaId))
          })
          .catch((error) =>
            addError(`Could not delete replica (${error.message})`)
          )
      })
      .catch((error) => {
        dispatch(deleteReplicaFailure(replicaId))
      })
  }
//################ SHARREPLICAE FORM ###################
const submitNewReplicaForm = (values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .post("/replicas", { replica: values })
      .then((response) => {
        if (response.data.errors) handleErrors({ errors: response.data.errors })
        else {
          dispatch(receiveReplica(response.data))
          handleSuccess()
          addNotice("Replica is being created.")
        }
      })
      .catch((error) => handleErrors({ errors: error.message }))
  })
const submitEditReplicaForm = (values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) => {
    let replicaId = values.id
    delete values["id"]

    ajaxHelper
      .put(`/replicas/${replicaId}`, { replica: values })
      .then((response) => {
        if (response.data.errors) handleErrors({ errors: response.data.errors })
        else {
          dispatch(receiveReplica(response.data))
          handleSuccess()
        }
      })
      .catch((error) => handleErrors({ errors: error.message }))
  })

//################ Resync ###################
const resyncReplica = (id) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) => {
    dispatch(requestReplica(id))
    ajaxHelper
      .post(`/replicas/${id}/resync`, {})
      .then((response) => {
        if (response.data.errors) {
          let errorMessage = ""
          for (let name in response.data.errors)
            errorMessage += `${name}: ${response.data.errors[name]}\n`
          addError(errorMessage)
          handleErrors({ errors: response.data.errors })
          dispatch(resetFetchingState(id))
        } else {
          dispatch(resetFetchingState(id))
          handleSuccess()
          addNotice("Replica has been synced.")
        }
      })
      .catch((error) => {
        addError(error.response?.data?.error || error.message)
        handleErrors({ errors: error.message })
        dispatch(resetFetchingState(id))
      })
  })

//################ Promote ###################
const promoteReplica = (id) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) => {
    dispatch(requestReplica(id))
    ajaxHelper
      .post(`/replicas/${id}/promote`, {})
      .then((response) => {
        if (response.data.errors || response.data.error) {
          let errorMessage = response.data.error || ""
          for (let name in response.data.errors)
            errorMessage += `${name}: ${response.data.errors[name]}\n`
          addError(errorMessage)
          handleErrors({ errors: response.data.errors })
          dispatch(requestReplicaFailure(id))
        } else {
          dispatch(receiveReplica(response.data))
          handleSuccess()
          addNotice("Replica has been promoted.")
        }
      })
      .catch((error) => {
        addError(error.response?.data?.error || error.message)
        handleErrors({ errors: error.message })
        dispatch(requestReplicaFailure(id))
      })
  })

// export
export {
  fetchReplicasIfNeeded,
  submitEditReplicaForm,
  submitNewReplicaForm,
  reloadReplica,
  deleteReplica,
  resyncReplica,
  promoteReplica,
}
