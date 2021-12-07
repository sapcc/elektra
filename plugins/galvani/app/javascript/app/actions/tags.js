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
      .catch((error) => handleErrors(error.message))
  )
}

const fetchConfig = () => {
  return new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .get(`/tags/config`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error.message)
      })
  )
}

export { fetchTags, fetchConfig }
