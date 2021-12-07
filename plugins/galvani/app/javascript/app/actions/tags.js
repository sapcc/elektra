import { ajaxHelper } from "ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice as showNotice, addError as showError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"

// const deleteEntry= entryId =>
//   function(dispatch, getState) {
//     confirm(`Do you really want to delete the entry ${entryId}?`).then(() => {
//       dispatch(requestDelete(entryId));
//       ajaxHelper.delete(`/entries/${entryId}`).then((response) => {
//         if (response.data && response.data.errors) {
//           showError(React.createElement(ErrorsList, {errors: response.data.errors}));
//           dispatch(deleteEntryFailure(entryId))
//         } else {
//           dispatch(removeEntry(entryId));
//         }
//       }).catch((error) => {
//         dispatch(deleteEntryFailure(entryId))
//         showError(React.createElement(ErrorsList, {errors: error.message}));
//       })
//     }).catch((aborted) => null)
//   }
// ;

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

const persistTags = () => {
  return new Promise((handleSuccess, handleErrors) =>
    fetchTags()
      .then((data) => {
        // dispatch
        handleSuccess(data.tags)
      })
      .catch((error) => {
        // dispatch
        handleErrors({ error })
      })
  )
}

const persistConfig = () => {
  return new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .get(`/tags/config`)
      .then((response) => {
        // dispatch
        handleSuccess(response.data.config)
      })
      .catch((error) => {
        // dispatch
        handleErrors(error.message)
      })
  )
}

export { fetchTags, persistTags, persistConfig }
