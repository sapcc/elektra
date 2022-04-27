import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice, addError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form"

const errorMessage = (error) =>
  (error.response && error.response.data && error.response.data.errors) ||
  error.message

//################### SHARE SERVERS #########################
const requestShareServers = () => ({
  type: constants.REQUEST_SHARE_SERVERS,
  requestedAt: Date.now(),
})
const requestShareServersFailure = (error) => ({
  type: constants.REQUEST_SHARE_SERVERS_FAILURE,
  error,
})
const receiveShareServers = (items) => ({
  type: constants.RECEIVE_SHARE_SERVERS,
  items,
  updatedAt: Date.now(),
})
const fetchShareServers = (shareNetworkId) =>
  function (dispatch) {
    dispatch(requestShareServers())
    ajaxHelper
      .get(`/share-networks/${shareNetworkId}/share-servers`)
      .then((response) =>
        dispatch(receiveShareServers(response.data.share_servers))
      )
      .catch((error) =>
        dispatch(requestShareServersFailure(errorMessage(error)))
      )
  }
const shouldFetchShareServers = function (state, shareNetworkId) {
  const { shareServers } = state
  if (shareServers.items.find((i) => i.share_network_id == shareNetworkId)) {
    return false
  }
  return true
}

const fetchShareServersIfNeeded = (shareNetworkId) =>
  function (dispatch, getState) {
    if (shouldFetchShareServers(getState(), shareNetworkId)) {
      return dispatch(fetchShareServers(shareNetworkId))
    }
  }
// export
export { fetchShareServersIfNeeded }
