import * as constants from "../constants"
import { ajaxHelper } from "ajax_helper"
import { addNotice as showNotice, addError as showError } from "lib/flashes"

//################### TYPES #########################
const request = () => ({
  type: constants.REQUEST_AGGREGATES,
  requestedAt: Date.now(),
})

const requestFailure = () => ({
  type: constants.REQUEST_AGGREGATES_FAILURE,
})

const receive = (json) => ({
  type: constants.RECEIVE_AGGREGATES,
  aggregates: json,
  receivedAt: Date.now(),
})

const fetch = () =>
  function (dispatch) {
    dispatch(request())
    ajaxHelper
      .get("/cache?type=aggregate")
      .then((response) => {
        return dispatch(receive(response.data.items))
      })
      .catch((error) => {
        dispatch(requestFailure())
        showError(`Could not load aggregates (${error.message})`)
      })
  }

const shouldFetch = function (state) {
  const { aggregates } = state.search
  if (aggregates.isFetching || aggregates.requestedAt) {
    return false
  } else {
    return true
  }
}

const fetchAggregatesIfNeeded = () =>
  function (dispatch, getState) {
    if (shouldFetch(getState())) {
      return dispatch(fetch())
    }
  }
export { fetchAggregatesIfNeeded }
