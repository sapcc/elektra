import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice as showNotice, addError as showError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"

//################### TYPES #########################
const requestTypes = () => ({
  type: constants.REQUEST_TYPES,
  requestedAt: Date.now(),
})

const requestTypesFailure = () => ({
  type: constants.REQUEST_TYPES_FAILURE,
})

const receiveTypes = (json) => ({
  type: constants.RECEIVE_TYPES,
  types: json,
  receivedAt: Date.now(),
})

const fetchTypes = () =>
  function (dispatch) {
    dispatch(requestTypes())
    ajaxHelper
      .get("/cache/types")
      .then((response) => {
        return dispatch(receiveTypes(response.data))
      })
      .catch((error) => {
        dispatch(requestTypesFailure())
        showError(`Could not load types (${error.message})`)
      })
  }

const shouldFetchTypes = function (state) {
  const { types } = state.search
  if (types.isFetching || types.requestedAt) {
    return false
  } else {
    return true
  }
}

const fetchTypesIfNeeded = () =>
  function (dispatch, getState) {
    if (shouldFetchTypes(getState())) {
      return dispatch(fetchTypes())
    }
  }
export { fetchTypesIfNeeded }
