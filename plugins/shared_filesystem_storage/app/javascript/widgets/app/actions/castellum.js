import * as constants from "../constants"
import { searchShareIDs } from "./shares"
import { createAjaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addError } from "lib/flashes"

let ajaxHelper = null

export const configureCastellumAjaxHelper = (opts) => {
  ajaxHelper = createAjaxHelper(opts)
}

const castellumErrorMessage = (error) =>
  (error.response && error.response.data) || error.message

const fetchCastellumData =
  (projectID, path, jsonKey = null) =>
  (dispatch, getState) => {
    dispatch({
      type: constants.REQUEST_CASTELLUM_DATA,
      path,
      requestedAt: Date.now(),
    })

    return ajaxHelper
      .get(`/v1/projects/${projectID}/${path}`)
      .then((response) => {
        const data = jsonKey ? response.data[jsonKey] : response.data
        if (Array.isArray(data)) {
          const shareIDs = data
            .map((elem) => elem.asset_id)
            .filter((elem) => (elem ? true : false))
          if (shareIDs.length > 0) {
            dispatch(searchShareIDs(shareIDs))
          }
        }
        dispatch({
          type: constants.RECEIVE_CASTELLUM_DATA,
          path,
          data,
          receivedAt: Date.now(),
        })
      })
      .catch((error) => {
        //for the resource config, a 404 response is not an error; it just shows
        //that autoscaling is disabled on this project resource
        if (
          path == "resources/nfs-shares" &&
          error.response &&
          error.response.status &&
          error.response.status == 404
        ) {
          dispatch({
            type: constants.RECEIVE_CASTELLUM_DATA,
            path,
            data: null,
            receivedAt: Date.now(),
          })
        } else {
          let msg = error.message
          if (error.response && error.response.data) {
            msg = `${msg}: ${error.response.data}`
          }
          dispatch({
            type: constants.REQUEST_CASTELLUM_DATA_FAILURE,
            path,
            message: msg,
          })
        }
      })
  }

export const fetchCastellumDataIfNeeded =
  (projectID, path, jsonKey = null) =>
  (dispatch, getState) => {
    const castellumState = getState().castellum || {}
    const { isFetching, requestedAt } = castellumState[path] || {}
    if (!isFetching && !requestedAt) {
      return dispatch(fetchCastellumData(projectID, path, jsonKey))
    }
  }

export const configureAutoscaling =
  (projectID, config) => (dispatch, getState) => {
    return new Promise((resolve, reject) =>
      ajaxHelper
        .put(`/v1/projects/${projectID}/resources/nfs-shares`, config)
        .catch((error) => {
          reject(castellumErrorMessage(error))
        })
        .then((response) => {
          if (response) {
            dispatch(fetchCastellumData(projectID, "resources/nfs-shares"))
            resolve()
          }
        })
    )
  }

export const disableAutoscaling = (projectID) => (dispatch, getState) => {
  confirm("Do you really want to disable autoscaling on this project?").then(
    () =>
      ajaxHelper
        .delete(`/v1/projects/${projectID}/resources/nfs-shares`)
        .catch((error) => addError(castellumErrorMessage(error)))
        .then((response) => {
          if (response) {
            dispatch(fetchCastellumData(projectID, "resources/nfs-shares"))
          }
        })
  )
}
