import * as constants from "../constants"
import { pluginAjaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice, addError } from "lib/flashes"

import { ErrorsList } from "lib/elektra-form/components/errors_list"

const ajaxHelper = pluginAjaxHelper("networking")

const errorMessage = (error) =>
  (error.response && error.response.data && error.response.data.errors) ||
  error.message

//################### SECURITY GROUPS #########################
const requestSecurityGroups = () => ({
  type: constants.REQUEST_SECURITY_GROUPS,
  requestedAt: Date.now(),
})
const requestSecurityGroupsFailure = () => ({
  type: constants.REQUEST_SECURITY_GROUPS_FAILURE,
})

const receiveSecurityGroups = (json) => ({
  type: constants.RECEIVE_SECURITY_GROUPS,
  securityGroups: json,
  receivedAt: Date.now(),
})
const fetcSecurityGroups = () =>
  function (dispatch, getState) {
    dispatch(requestSecurityGroups())

    return ajaxHelper
      .get("/security-groups")
      .then((response) => {
        dispatch(receiveSecurityGroups(response.data.security_groups))
      })
      .catch((error) => {
        dispatch(requestSecurityGroupsFailure())
        addError(
          React.createElement(ErrorsList, {
            errors: errorMessage(error),
          })
        )
      })
  }
const shouldFetchSecurityGroups = function (state) {
  if (state.securityGroups.isFetching || state.securityGroups.requestedAt) {
    return false
  } else {
    return true
  }
}

const fetchSecurityGroupsIfNeeded = () =>
  function (dispatch, getState) {
    if (shouldFetchSecurityGroups(getState())) {
      return dispatch(fetcSecurityGroups())
    }
  }
//################### SECURITY GROUP #########################
const receiveSecurityGroup = (securityGroup) => ({
  type: constants.RECEIVE_SECURITY_GROUP,
  securityGroup,
})
const requestSecurityGroupDelete = (id) => ({
  type: constants.REQUEST_SECURITY_GROUP_DELETE,
  id,
})

const removeSecurityGroup = (id) => ({
  type: constants.REMOVE_SECURITY_GROUP,
  id,
})

const fetchSecurityGroup = (id) => (dispatch) => {
  return new Promise((handleSuccess, handleError) =>
    ajaxHelper
      .get(`/security-groups/${id}`)
      .then((response) => {
        dispatch(receiveSecurityGroup(response.data.security_group))
        handleSuccess(response.data.security_group)
      })
      .catch((error) => {
        if (error.response.status == 404) {
          // remove from state
          dispatch(removeSecurityGroup(id))
        }
        // set state to not loading
        dispatch(requestSecurityGroupsFailure())
        // add error
        addError(
          React.createElement(ErrorsList, {
            errors: errorMessage(error),
          })
        )
        handleError(errorMessage(error))
      })
  )
}

const deleteSecurityGroup = (id) => (dispatch) =>
  confirm(`Do you really want to delete the securit group ${id}?`)
    .then(() => {
      dispatch(requestSecurityGroupDelete(id))
      return ajaxHelper
        .delete(`/security-groups/${id}`)
        .then((response) => dispatch(removeSecurityGroup(id)))
        .catch((error) => {
          addError(
            React.createElement(ErrorsList, {
              errors: errorMessage(error),
            })
          )
        })
    })
    .catch((cancel) => true)

const submitNewSecurityGroupForm = (values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .post("/security-groups/", { security_group: values })
      .then((response) => {
        dispatch(receiveSecurityGroup(response.data))
        handleSuccess()
      })
      .catch((error) => handleErrors({ errors: errorMessage(error) }))
  )

const submitEditSecurityGroupForm = (id, values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .put(`/security-groups/${id}`, { security_group: values })
      .then((response) => {
        dispatch(receiveSecurityGroup(response.data))
        handleSuccess()
      })
      .catch((error) => handleErrors({ errors: errorMessage(error) }))
  )

export {
  fetchSecurityGroupsIfNeeded,
  fetchSecurityGroup,
  deleteSecurityGroup,
  submitNewSecurityGroupForm,
  submitEditSecurityGroupForm,
}
