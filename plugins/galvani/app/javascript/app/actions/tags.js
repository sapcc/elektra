import { ajaxHelper } from "ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice as showNotice, addError as showError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"

const fetchTags = () => {
  return new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .get(`/tags`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => handleErrors(error.response))
  )
}

const removeTag = (service, tag) => {
  return new Promise((handleSuccess, handleErrors) => {
    return ajaxHelper
      .delete(`/tags/${id}`)
      .then((response) => {
        // dispatch({ type: "REQUEST_REMOVE_LOADBALANCER", id: id });
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error.response)
      })
  })
}

const fetchConfig = () => {
  return new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .get(`/tags/config`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error.response)
      })
  )
}

export { fetchTags, removeTag, fetchConfig }
