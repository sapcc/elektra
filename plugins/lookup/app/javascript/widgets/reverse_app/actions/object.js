import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"
import { fetchDomain } from "./domain"
import { fetchParents } from "./parents"
import { fetchUsers } from "./users"
import { fetchGroups } from "./groups"
import { fetchProject } from "./project"

//################### OBJECT #########################

const setSearchedValue = (searchedValue) => ({
  type: constants.SET_SEARCHED_VALUE,
  searchedValue,
})

const requestObject = () => ({
  type: constants.REQUEST_OBJECT,
  requestedAt: Date.now(),
})

const receiveObject = (json) => ({
  type: constants.RECEIVE_OBJECT,
  data: json,
  receivedAt: Date.now(),
})

const requestObjectFailure = (err) => ({
  type: constants.REQUEST_OBJECT_FAILURE,
  error: err,
})

const resetStore = () => ({
  type: constants.RESET_STORE,
})

const fetchObject = (value) => (dispatch, getState) =>
  new Promise((handleSuccess, handleErrors) => {
    if (!value.trim()) {
      handleErrors({ errors: `Input field is empty or contains only spaces.` })
      return
    }
    dispatch(resetStore())
    dispatch(setSearchedValue(value))
    dispatch(requestObject())
    ajaxHelper
      .post(`/reverselookup/search`, { searchValue: value })
      .then((response) => {
        if (response.data.errors) {
          dispatch(
            requestObjectFailure(
              `Could not load object (${response.data.errors})`
            )
          )
        } else {
          const searchValue = response.data.searchValue
          const searchedValue = getState().object.searchedValue
          if (searchValue != searchedValue) return
          dispatch(receiveObject(response.data))
          if (
            response.data.projectId != "" &&
            typeof response.data.projectId !== "undefined"
          ) {
            dispatch(fetchProject(searchValue, response.data.projectId))
            dispatch(fetchDomain(searchValue, response.data.projectId))
            dispatch(fetchParents(searchValue, response.data.projectId))
            dispatch(fetchUsers(searchValue, response.data.projectId))
            dispatch(fetchGroups(searchValue, response.data.projectId))
          }
          handleSuccess()
        }
      })
      .catch((error) => {
        dispatch(
          requestObjectFailure(`Could not load object (${error.message})`)
        )
      })
  })

//################### OBJECT INFO #########################

const requestObjectInfo = () => ({
  type: constants.REQUEST_OBJECTINFO,
  requestedAt: Date.now(),
})

const receiveObjectInfo = (json) => ({
  type: constants.RECEIVE_OBJECTINFO,
  data: json,
  receivedAt: Date.now(),
})

const requestObjectInfoFailure = (err) => ({
  type: constants.REQUEST_OBJECTINFO_FAILURE,
  error: err,
})

const fetchObjectInfo = (searchValue, objectId, searchBy) =>
  function (dispatch, getSate) {
    dispatch(requestObjectInfo())
    ajaxHelper
      .get(`/reverselookup/object_info/${objectId}?searchBy=${searchBy}`)
      .then((response) => {
        const searchedValue = getSate().object.searchedValue
        if (searchValue != searchedValue) return
        return dispatch(receiveObjectInfo(response.data))
      })
      .catch((error) => {
        dispatch(
          requestObjectInfoFailure(
            `Could not load object info (${error.message})`
          )
        )
      })
  }

export { fetchObject, fetchObjectInfo }
