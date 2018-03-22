import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { fetchDomain } from './domain';
import { fetchParents } from './parents';
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

const requestProjectFailure= (err) => (
  {
    type: constants.REQUEST_PROJECT_FAILURE,
    error: err
  }
);

//################ PROJECT FORM ###################
const fetchProjectForm= (value) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) => {
      if (!value.trim()) {
        showError(`Input field is empty or contains only spaces.`)
        handleErrors({errors: `Input field is empty or contains only spaces.`})
        return
      }
      dispatch(requestProject())
      ajaxHelper.post(
        `/reverselookup/search`,
        {searchValue: value}
      ).then((response) => {
        if (response.data.errors) {
          dispatch(requestProjectFailure(`Could not load project (${response.data.errors})`))
          handleErrors({errors: response.data.errors})
        }else {
          dispatch(receiveProject(response.data))
          dispatch(fetchDomain(response.data.domainId))
          dispatch(fetchParents(response.data.id))
          handleSuccess()
        }
      }).catch(error => {
        dispatch(requestProjectFailure(`Could not load project (${error.message})`))
        handleErrors({errors: error.message})
      })
    })
);

export {
  fetchProjectForm
}
