import React from "react"
import { useDispatch } from "../../components/StateProvider"
import { confirm } from "lib/dialogs"
import { createNameTag } from "../../helpers/commonHelpers"
import {
  fetchHealthmonitor,
  postHealthMonitor,
  putHealthmonitor,
  deleteHealthmonitor,
} from "../../actions/healthMonitor"

const useHealthMonitor = () => {
  const dispatch = useDispatch()

  const persistHealthmonitor = (lbID, poolID, healthmonitorID, options) => {
    dispatch({ type: "RESET_HEALTHMONITOR" })
    dispatch({ type: "REQUEST_HEALTHMONITOR" })
    return new Promise((handleSuccess, handleError) => {
      fetchHealthmonitor(lbID, poolID, healthmonitorID, options)
        .then((data) => {
          dispatch({
            type: "RECEIVE_HEALTHMONITOR",
            healthmonitor: data.healthmonitor,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_HEALTHMONITOR_FAILURE", error: error })
          if (error && error.status == 404) {
            dispatch({ type: "REMOVE_HEALTHMONITOR", id: healthmonitorID })
          }
          handleError(error)
        })
    })
  }

  const pollHealthmonitor = (lbID, poolID, healthmonitorID) => {
    dispatch({ type: "REQUEST_HEALTHMONITOR" })
    return new Promise((handleSuccess, handleError) => {
      fetchHealthmonitor(lbID, poolID, healthmonitorID)
        .then((data) => {
          dispatch({
            type: "RECEIVE_HEALTHMONITOR",
            healthmonitor: data.healthmonitor,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          if (error && error.status == 404) {
            dispatch({ type: "REMOVE_HEALTHMONITOR", id: healthmonitorID })
          }
          handleError(error)
        })
    })
  }

  const createHealthMonitor = (lbID, poolID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      postHealthMonitor(lbID, poolID, values)
        .then((data) => {
          dispatch({
            type: "RECEIVE_HEALTHMONITOR",
            healthmonitor: data,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updateHealthmonitor = (lbID, poolID, healthmonitorID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      putHealthmonitor(lbID, poolID, healthmonitorID, values)
        .then((data) => {
          dispatch({
            type: "RECEIVE_HEALTHMONITOR",
            healthmonitor: data,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const removeHealthmonitor = (
    lbID,
    poolID,
    healthmonitorID,
    healthmonitorName
  ) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(
        <React.Fragment>
          <p>Do you really want to delete following Health Monitor?</p>
          <p>
            {createNameTag(healthmonitorName)} <b>id:</b> {healthmonitorID}
          </p>
        </React.Fragment>
      )
        .then(() => {
          return deleteHealthmonitor(lbID, poolID, healthmonitorID)
            .then((data) => {
              dispatch({ type: "REQUEST_REMOVE_HEALTHMONITOR" })
              handleSuccess(data)
            })
            .catch((error) => {
              handleErrors(error)
            })
        })
        .catch((cancel) => true)
    })
  }

  const resetState = () => {
    dispatch({ type: "RESET_HEALTHMONITOR" })
  }

  return {
    persistHealthmonitor,
    pollHealthmonitor,
    createHealthMonitor,
    updateHealthmonitor,
    removeHealthmonitor,
    resetState,
  }
}

export default useHealthMonitor
