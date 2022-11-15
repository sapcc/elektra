import { ajaxHelper } from "lib/ajax_helper"

export const fetchPools = (lbID, options) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/${lbID}/pools`, { params: options })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const fetchPool = (lbID, poolID) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/${lbID}/pools/${poolID}`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const postPool = (lbID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .post(`/loadbalancers/${lbID}/pools`, { pool: values })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const putPool = (lbID, poolID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .put(`/loadbalancers/${lbID}/pools/${poolID}`, { pool: values })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const deletePool = (lbID, poolID) => {
  return new Promise((handleSuccess, handleErrors) => {
    return ajaxHelper
      .delete(`/loadbalancers/${lbID}/pools/${poolID}`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const fetchPoolsForSelect = (lbID) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/${lbID}/pools/items_for_select`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}
