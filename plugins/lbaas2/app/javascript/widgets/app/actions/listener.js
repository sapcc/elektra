import { ajaxHelper } from "lib/ajax_helper"

export const fetchListeners = (lbID, options) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/${lbID}/listeners`, { params: options })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const fetchListener = (lbID, id) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/${lbID}/listeners/${id}`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const postListener = (lbID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .post(`/loadbalancers/${lbID}/listeners`, { listener: values })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const putListener = (lbID, listenerID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .put(`/loadbalancers/${lbID}/listeners/${listenerID}`, {
        listener: values,
      })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const deleteListener = (lbID, listenerID) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .delete(`/loadbalancers/${lbID}/listeners/${listenerID}`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const fetchListnersNoDefaultPoolForSelect = (lbID) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/${lbID}/listeners/items_no_def_pool_for_select`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const fetchListnersForSelect = (lbID) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/${lbID}/listeners/items_for_select`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const fetchSecretsForSelect = (options) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/secretss`, { params: options })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const fetchCiphers = () => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .get(`/loadbalancers/ciphers`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}
