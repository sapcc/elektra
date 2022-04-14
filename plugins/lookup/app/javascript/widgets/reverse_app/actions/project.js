import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"

//################### PROJECT #########################
const requestProject = () => ({
  type: constants.REQUEST_PROJECT,
  requestedAt: Date.now(),
})

const receiveProject = (json) => ({
  type: constants.RECEIVE_PROJECT,
  data: json,
  receivedAt: Date.now(),
})

const requestProjectFailure = (err) => ({
  type: constants.REQUEST_PROJECT_FAILURE,
  error: err,
})

const fetchProject = (searchValue, projectId) =>
  function (dispatch, getState) {
    dispatch(requestProject())
    ajaxHelper
      .get(`/reverselookup/project/${projectId}`)
      .then((response) => {
        const searchedValue = getState().object.searchedValue
        if (searchValue != searchedValue) return
        return dispatch(receiveProject(response.data))
      })
      .catch((error) => {
        dispatch(
          requestProjectFailure(`Could not load Project (${error.message})`)
        )
      })
  }

export { fetchProject }
