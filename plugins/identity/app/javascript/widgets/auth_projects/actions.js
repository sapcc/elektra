import * as constants from "./constants"
import { ErrorsList } from "lib/elektra-form/components/errors_list"
import { pluginAjaxHelper } from "lib/ajax_helper"

const ajaxHelper = pluginAjaxHelper("identity", { project: false })

//################### AUTH PROJECTS #########################
const toggleModal = () => ({
  type: constants.TOGGLE_MODAL,
})
const requestAuthProjects = () => ({
  type: constants.REQUEST_AUTH_PROJECTS,
  requestedAt: Date.now(),
})
const requestFailure = () => ({ type: constants.REQUEST_AUTH_PROJECTS_FAILURE })

const receiveAuthProjects = (json) => ({
  type: constants.RECEIVE_AUTH_PROJECTS,
  items: json,
  receivedAt: Date.now(),
})
const fetchAuthProjects = () =>
  function (dispatch, getState) {
    dispatch(requestAuthProjects())

    return new Promise((handleSuccess, handleErrors) =>
      ajaxHelper
        .get("/domains/auth_projects")
        .then((response) => {
          if (response.data.errors) {
            dispatch(requestFailure())
            handleErrors(response.data.errors)
          } else {
            dispatch(receiveAuthProjects(response.data.auth_projects))
            handleSuccess()
          }
        })
        .catch((error) => {
          dispatch(requestFailure())
          handleErrors(error.message)
        })
    )
  }
const shouldFetchAuthProjects = function (state) {
  if (state.authProjects.isFetching || state.authProjects.requestedAt) {
    return false
  } else {
    return true
  }
}

const fetchAuthProjectsIfNeeded = () =>
  function (dispatch, getState) {
    if (shouldFetchAuthProjects(getState())) {
      return dispatch(fetchAuthProjects())
    }
  }
export { fetchAuthProjectsIfNeeded, toggleModal }
