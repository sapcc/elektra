import * as constants from "../constants"
import { pluginAjaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice as showNotice, addError as showError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"

const ajaxHelper = pluginAjaxHelper("identity")

//################### OBJECTS #########################
const requestUserRoleAssignments = (userId) => ({
  type: constants.REQUEST_USER_ROLE_ASSIGNMENTS,
  requestedAt: Date.now(),
  userId,
})

const requestUserRoleAssignmentsFailure = (userId) => ({
  type: constants.REQUEST_USER_ROLE_ASSIGNMENTS_FAILURE,
  userId,
})

const receiveUserRoleAssignments = (userId, roles) => ({
  type: constants.RECEIVE_USER_ROLE_ASSIGNMENTS,
  receivedAt: Date.now(),
  userId,
  roles,
})

const fetchUserRoleAssignments = (userId) => (dispatch, getState) => {
  const userRoleAssignments =
    getState()["role_assignments"]["user_role_assignments"]
  if (
    userRoleAssignments &&
    userRoleAssignments[userId] &&
    userRoleAssignments[userId].isFetching
  )
    return
  dispatch(requestUserRoleAssignments(userId))
  ajaxHelper
    .get(`/users/${userId}/role_assignments`)
    .then((response) => {
      dispatch(receiveUserRoleAssignments(userId, response.data.roles))
    })
    .catch((error) => {
      dispatch(requestUserRoleAssignmentsFailure())
      showError(`Could not load user role assignments (${error.message})`)
    })
}
export { fetchUserRoleAssignments }
