import { ajaxHelper } from "lib/ajax_helper"

import * as constants from "../constants"

const errorMessage = (error) => error.data || error.message

////////////////////////////////////////////////////////////////////////////////

const fetchErrors = (errorType) => (dispatch) => {
  dispatch({
    type: constants.REQUEST_CASTELLUM_ERRORS,
    errorType,
    requestedAt: Date.now(),
  })

  return ajaxHelper
    .get(`/v1/admin/${errorType}`)
    .then((response) => {
      const jsonKey = errorType.replace(/-/g, "_") //e.g. "asset-scrape-errors" -> "asset_scrape_errors"
      dispatch({
        type: constants.RECEIVE_CASTELLUM_ERRORS,
        errorType,
        data: response.data[jsonKey] || [],
        receivedAt: Date.now(),
      })
    })
    .catch((error) => {
      dispatch({
        type: constants.REQUEST_CASTELLUM_ERRORS_FAILURE,
        errorType,
        errorMessage: errorMessage(error),
      })
    })
}

const fetchErrorsIfNeeded = (errorType) => (dispatch, getState) => {
  const state = getState().castellum[errorType]
  if (state.isFetching || state.requestedAt) {
    return
  }
  return dispatch(fetchErrors(errorType))
}

const refetchErrorsOnDemand = () => (dispatch) => {
  for (const errorType of constants.CASTELLUM_ERROR_TYPES) {
    dispatch(fetchErrors(errorType))
  }
}

export const fetchAllErrorsAsNeeded = () => (dispatch) => {
  for (const errorType of constants.CASTELLUM_ERROR_TYPES) {
    dispatch(fetchErrorsIfNeeded(errorType))
  }
}

const clearError = (error) => (dispatch) => {
  const { project_id, asset_type, asset_id } = error
  return new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .post(`/v1/projects/${project_id}/assets/${asset_type}/${asset_id}/error-resolved`)
      .then(() => {
        handleSuccess()
        dispatch(refetchErrorsOnDemand())
      })
      .catch((error) => handleErrors(console.log(errorMessage(error))))
  )
}

export const clearErrorIfNeeded = (error) => (dispatch) => {
  dispatch(clearError(error))
}
