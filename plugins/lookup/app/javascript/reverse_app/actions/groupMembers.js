import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"

//################### GROUP MEMBERS #########################
const requestGroupMembers = (groupId) => ({
  groupId: groupId,
  type: constants.REQUEST_GROUPMEMBERS,
  requestedAt: Date.now(),
})

const receiveGroupMembers = (groupId, json) => ({
  groupId: groupId,
  type: constants.RECEIVE_GROUPMEMBERS,
  data: json,
  receivedAt: Date.now(),
})

const requestGroupMembersFailure = (groupId, err) => ({
  groupId: groupId,
  type: constants.REQUEST_GROUPMEMBERS_FAILURE,
  error: err,
})

const fetchGroupMembers = (groupId) =>
  function (dispatch) {
    dispatch(requestGroupMembers(groupId))
    ajaxHelper
      .get(`/reverselookup/group_members/${groupId}`)
      .then((response) => {
        return dispatch(receiveGroupMembers(groupId, response.data))
      })
      .catch((error) => {
        dispatch(
          requestGroupMembersFailure(
            groupId,
            `Could not load group members (${error.message})`
          )
        )
      })
  }

export { fetchGroupMembers }
