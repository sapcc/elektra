import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { addNotice as showNotice, addError as showError } from 'lib/flashes';

//################### PROJECT #########################
const requestProject= json => (
  {
    type: constants.REQUEST_PROJECT,
    requestedAt: Date.now()
  }
);

const receiveProject= json => (
  {
    type: constants.RECEIVE_PROJECT,
    data: json,
    receivedAt: Date.now()
  }
);

const requestProjectFailure= () => (
  {
    type: constants.REQUEST_PROJECT_FAILURE,
  }
);

//################ PROJECT FORM ###################
const fetchProjectForm= (value) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) => {
      if (!value.trim()) {
        showError(`Input field is empty or contains only spaces.`)
        dispatch(requestProjectFailure())
        return
      }
      dispatch(requestProject())
      ajaxHelper.post(
        `/reverselookup/search`,
        {searchValue: value}
      ).then((response) => {
        if (response.data.errors) {
          dispatch(requestProjectFailure())
          showError(response.data.errors)
          // handleErrors({errors: response.data.errors})
        }else {
          dispatch(receiveProject(response.data))
          handleSuccess()
        }
      }).catch(error => {
        dispatch(requestProjectFailure())
        showError(error.message)
        // handleErrors({errors: error.message})
      })
    })
);

export {
  fetchProjectForm
}
