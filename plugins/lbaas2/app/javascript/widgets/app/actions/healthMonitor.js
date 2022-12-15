import { ajaxHelper } from "lib/ajax_helper"

export const fetchHealthmonitor = (lbID, poolID, healthmonitorID, options) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(
        `/loadbalancers/${lbID}/pools/${poolID}/healthmonitors/${healthmonitorID}`,
        { params: options }
      )
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const postHealthMonitor = (lbID, poolID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .post(`/loadbalancers/${lbID}/pools/${poolID}/healthmonitors`, {
        healthmonitor: values,
      })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const putHealthmonitor = (lbID, poolID, healthmonitorID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .put(
        `/loadbalancers/${lbID}/pools/${poolID}/healthmonitors/${healthmonitorID}`,
        { healthmonitor: values }
      )
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const deleteHealthmonitor = (lbID, poolID, healthmonitorID) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .delete(
        `/loadbalancers/${lbID}/pools/${poolID}/healthmonitors/${healthmonitorID}`
      )
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}
