import { ajaxHelper } from "lib/ajax_helper"

import * as constants from "../constants"

const errorMessage = (error) =>
  (error.response && error.response.data) || error.message

////////////////////////////////////////////////////////////////////////////////

const fetchErrors = (errorType) => (dispatch) => {
  dispatch({
    type: constants.REQUEST_LIMES_ERRORS,
    errorType,
    requestedAt: Date.now(),
  })

  // rate scrape errors have moved from `/v1/admin/rate-scrape-errors` to `/rates/v1/admin/scrape-errors`
  const errorsURL = errorType == "rate-scrape-errors" ? "/rates/v1/admin/scrape-errors" : `/v1/admin/${errorType}`

  return ajaxHelper
    .get(errorsURL)
    .then((response) => {
      const jsonKey = errorType.replace(/-/g, "_") //e.g. "asset-scrape-errors" -> "asset_scrape_errors"
      dispatch({
        type: constants.RECEIVE_LIMES_ERRORS,
        errorType,
        data: response.data[jsonKey] || [],
        receivedAt: Date.now(),
      })
    })
    .catch((error) => {
      dispatch({
        type: constants.REQUEST_LIMES_ERRORS_FAILURE,
        errorType,
        errorMessage: errorMessage(error),
      })
    })
}

const fetchErrorsIfNeeded = (errorType) => (dispatch, getState) => {
  const state = getState().limes[errorType]
  if (state.isFetching || state.requestedAt) {
    return
  }
  return dispatch(fetchErrors(errorType))
}

export const fetchAllErrorsAsNeeded = () => (dispatch) => {
  for (const errorType of constants.LIMES_ERROR_TYPES) {
    dispatch(fetchErrorsIfNeeded(errorType))
  }
}
