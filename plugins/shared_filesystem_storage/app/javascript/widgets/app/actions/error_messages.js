import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"
import { addNotice, addError } from "lib/flashes"
import React from "react"
import { ErrorsList } from "lib/elektra-form/components/errors_list"

//################### SHARES #########################
const requestErrorMessages = (resourceId) => ({
  type: constants.REQUEST_ERROR_MESSAGES,
  resourceId,
  requestedAt: Date.now(),
})

const requestErrorMessagesFailure = (resourceId) => ({
  type: constants.REQUEST_ERROR_MESSAGES_FAILURE,
  resourceId,
})

const receiveErrorMessages = (resourceId, json, hasNext) => ({
  type: constants.RECEIVE_ERROR_MESSAGES,
  messages: json,
  resourceId,
  hasNext,
  receivedAt: Date.now(),
})

const setSearchTerm = (resourceId, searchTerm) => ({
  type: constants.SET_ERROR_MESSAGE_SEARCH_TERM,
  resourceId,
  searchTerm,
})

const fetchErrorMessages = (resourceId, page) =>
  function (dispatch, getState) {
    dispatch(requestErrorMessages(resourceId))

    return ajaxHelper
      .get("/error_messages", { params: { page, resource_id: resourceId } })
      .then((response) => {
        if (response.data.errors) {
          addError(
            React.createElement(ErrorsList, { errors: response.data.errors })
          )
        } else {
          dispatch(
            receiveErrorMessages(
              resourceId,
              response.data.error_messages,
              response.data.has_next
            )
          )
        }
      })
      .catch((error) => {
        dispatch(requestErrorMessagesFailure(resourceId))
        addError(`Could not load error messages (${error.message})`)
      })
  }
const loadNext = (resourceId) =>
  function (dispatch, getState) {
    let { errorMessages } = getState()
    errorMessages = errorMessages[resourceId] || {}

    if (!errorMessages.isFetching && errorMessages.hasNext) {
      dispatch(fetchErrorMessages(errorMessages.currentPage + 1)).then(() => {
        // load next if search modus (searchTerm is presented)
        dispatch(loadNextOnSearch(errorMessages.searchTerm))
      })
    }
  }
const loadNextOnSearch = (resourceId, searchTerm) =>
  function (dispatch) {
    if (searchTerm && searchTerm.trim().length > 0) {
      dispatch(loadNext(resourceId))
    }
  }
const searchErrorMessages = (resourceId, searchTerm) =>
  function (dispatch) {
    dispatch(setSearchTerm(resourceId, searchTerm))
    dispatch(loadNextOnSearch(resourceId, searchTerm))
  }
const shouldFetchErrorMessages = function (resourceId, state) {
  let { errorMessages } = state
  errorMessages = errorMessages[resourceId] || {}

  if (errorMessages.isFetching || errorMessages.requestedAt) {
    return false
  } else {
    return true
  }
}

const fetchErrorMessagesIfNeeded = (resourceId) =>
  function (dispatch, getState) {
    if (shouldFetchErrorMessages(resourceId, getState())) {
      return dispatch(fetchErrorMessages(resourceId))
    }
  }
export { fetchErrorMessagesIfNeeded, searchErrorMessages, loadNext }
