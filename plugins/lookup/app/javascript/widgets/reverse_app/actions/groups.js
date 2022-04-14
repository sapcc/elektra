import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"

//################### GROUPS #########################
const requestGroups = (json) => ({
  type: constants.REQUEST_GROUPS,
  requestedAt: Date.now(),
})

const receiveGroups = (json) => ({
  type: constants.RECEIVE_GROUPS,
  data: json,
  receivedAt: Date.now(),
})

const requestGroupsFailure = (err) => ({
  type: constants.REQUEST_GROUPS_FAILURE,
  error: err,
})

const fetchGroups = (searchValue, projectId) =>
  function (dispatch, getState) {
    dispatch(requestGroups())
    ajaxHelper
      .get(`/reverselookup/groups/${projectId}`)
      .then((response) => {
        const searchedValue = getState().object.searchedValue
        if (searchValue != searchedValue) return
        return dispatch(receiveGroups(response.data))
      })
      .catch((error) => {
        dispatch(
          requestGroupsFailure(`Could not load groups (${error.message})`)
        )
      })
  }

export { fetchGroups }
