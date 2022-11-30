import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice, addError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"
import React from "react"

//################### SECURITY_SERVICES #########################
const requestSecurityServices = () => ({
  type: constants.REQUEST_SECURITY_SERVICES,
  requestedAt: Date.now(),
})
const requestSecurityServicesFailure = () => ({
  type: constants.REQUEST_SECURITY_SERVICES_FAILURE,
})

const receiveSecurityServices = (json) => ({
  type: constants.RECEIVE_SECURITY_SERVICES,
  securityServices: json,
  receivedAt: Date.now(),
})
const requestSecurityService = (securityServiceId) => ({
  type: constants.REQUEST_SECURITY_SERVICE,
  securityServiceId,
  requestedAt: Date.now(),
})
const requestSecurityServiceFailure = (securityServiceId) => ({
  type: constants.REQUEST_SECURITY_SERVICE_FAILURE,
  securityServiceId,
})
const receiveSecurityService = (json) => ({
  type: constants.RECEIVE_SECURITY_SERVICE,
  securityService: json,
})
const fetchSecurityServices = () =>
  function (dispatch) {
    dispatch(requestSecurityServices())
    ajaxHelper
      .get("/security-services")
      .then((response) => {
        dispatch(receiveSecurityServices(response.data))
      })
      .catch((error) => {
        dispatch(requestSecurityServicesFailure())
        addError(`Could not load security services (${error.message})`)
      })
  }
const shouldFetchSecurityServices = function (state) {
  const { securityServices } = state
  if (securityServices.isFetching || securityServices.requestedAt) {
    return false
  } else {
    return true
  }
}

const fetchSecurityServicesIfNeeded = () =>
  function (dispatch, getState) {
    if (shouldFetchSecurityServices(getState())) {
      return dispatch(fetchSecurityServices())
    }
  }
const canReloadSecurityService = function (state, securityServiceId) {
  const { items } = state.securityServices
  let index = -1
  for (let i = 0; i < items.length; i++) {
    const item = items[i]
    if (item.id === securityServiceId) {
      index = i
      break
    }
  }
  if (index < 0) {
    return true
  }
  return !items[index].isFetching
}

const reloadSecurityService = (securityServiceId) =>
  function (dispatch, getState) {
    if (!canReloadSecurityService(getState(), securityServiceId)) {
      return
    }

    dispatch(requestSecurityService(securityServiceId))
    ajaxHelper
      .get(`/security-services/${securityServiceId}`)
      .then((response) => {
        dispatch(receiveSecurityService(data))
      })
      .catch((error) => {
        dispatch(requestSecurityServiceFailure())
        addError(`Could not reload security service (${error.message})`)
      })
  }
const requestDelete = (securityServiceId) => ({
  type: constants.REQUEST_DELETE_SECURITY_SERVICE,
  securityServiceId,
})
const deleteSecurityServiceFailure = (securityServiceId) => ({
  type: constants.DELETE_SECURITY_SERVICE_FAILURE,
  securityServiceId,
})
const removeSecurityService = (securityServiceId) => ({
  type: constants.DELETE_SECURITY_SERVICE_SUCCESS,
  securityServiceId,
})
const deleteSecurityService = (securityServiceId) =>
  function (dispatch, getState) {
    const dependentSecurityServiceNetworks = []
    // check if there are dependent securityService networks.
    // Problem: the securityService networks may not be loaded yet
    let state = getState()
    const { securityServiceNetworks } = state
    if (securityServiceNetworks && securityServiceNetworks.items) {
      for (let securityServiceNetwork of securityServiceNetworks.items) {
        if (false) {
          dependentSecurityServiceNetworks.push(securityServiceNetwork)
        }
      }
    }

    if (dependentSecurityServiceNetworks.length > 0) {
      addNotice(
        `Please remove thi security service from securityService networks (${dependentSecurityServiceNetworks.length}) first!`
      )
      return
    }

    confirm("Do you really want to delete this security service?")
      .then(() => {
        dispatch(requestDelete(securityServiceId))
        ajaxHelper
          .delete(`/security-services/${securityServiceId}`)
          .then((response) => {
            if (response.data && response.data.errors) {
              dispatch(deleteSecurityServiceFailure(securityServiceId))
              addError(
                React.createElement(ErrorsList, {
                  errors: response.data.errors,
                })
              )
            } else {
              dispatch(removeSecurityService(securityServiceId))
            }
          })
          .catch((error) => {
            addError(React.createElement(ErrorsList, { errors: error.message }))
          })
      })
      .catch((error) => null)
  }
//################ SECURITY_SERVICE FORM ###################

const submitNewSecurityServiceForm = (values) => (dispatch, getState) =>
  new Promise((handleSuccess, handleErrors) => {
    const { securityServiceForm } = getState()

    ajaxHelper
      .post("/security-services", { security_service: values })
      .then((response) => {
        if (response.data.errors) handleErrors({ errors: response.data.errors })
        else {
          dispatch(receiveSecurityService(response.data))
          handleSuccess()
        }
      })
      .catch((error) => handleErrors({ errors: error.message }))
  })
const submitEditSecurityServiceForm = (values) => (dispatch, getState) =>
  new Promise((handleSuccess, handleErrors) => {
    const { securityServiceForm } = getState()
    let id = values.id
    delete values["id"]

    ajaxHelper
      .put(`/security-services/${id}`, { security_service: values })
      .then((response) => {
        if (response.data.errors) handleErrors({ errors: response.data.errors })
        else {
          dispatch(receiveSecurityService(response.data))
          handleSuccess()
        }
      })
      .catch((error) => handleErrors({ errors: error.message }))
  })
// export
export {
  fetchSecurityServices,
  fetchSecurityServicesIfNeeded,
  reloadSecurityService,
  deleteSecurityService,
  submitNewSecurityServiceForm,
  submitEditSecurityServiceForm,
}
