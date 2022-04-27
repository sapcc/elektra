import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"
import { addNotice, addError } from "lib/flashes"

//################ SHARE TYPES ################
const receiveShareTypes = (shareTypes) => ({
  type: constants.RECEIVE_SHARE_TYPES,
  shareTypes,
  receivedAt: Date.now(),
})
const requestShareTypes = () => ({
  type: constants.REQUEST_SHARE_TYPES,
  requestedAt: Date.now(),
})
const fetchShareTypes = () =>
  function (dispatch) {
    dispatch(requestShareTypes())
    ajaxHelper
      .get(`/share_types`)
      .then((response) => {
        if (response.data.errors) {
          addError(
            React.createElement(ErrorsList, { errors: response.data.errors })
          )
        } else {
          dispatch(receiveShareTypes(response.data))
        }
      })
      .catch((error) => {
        addError(`Could not load share types (${error.message})`)
      })
  }
const shouldFetchShareTypes = function (state) {
  const shareTypes = state.shareTypes
  if (!shareTypes.isFetching && !shareTypes.requestedAt) return true
  return false
}

const fetchShareTypesIfNeeded = () =>
  function (dispatch, getState) {
    if (shouldFetchShareTypes(getState())) {
      return dispatch(fetchShareTypes())
    }
  }
// export
export { fetchShareTypesIfNeeded }
