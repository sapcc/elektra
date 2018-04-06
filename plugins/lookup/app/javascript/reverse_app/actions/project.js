import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { fetchDomain } from './domain';
import { fetchParents } from './parents';
import { fetchUsers } from './users';
import { fetchGroups } from './groups';

//################### PROJECT #########################

const setSearchedValue= searchedValue => (
  {
    type: constants.SET_SEARCHED_VALUE,
    searchedValue
  }
);

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

const resetStore= () => (
  {
    type: constants.RESET_STORE
  }
);

//################ PROJECT FORM ###################
const fetchProjectForm= (value) => (
  (dispatch,getState) =>
    new Promise((handleSuccess,handleErrors) => {
      if (!value.trim()) {
        handleErrors({errors: `Input field is empty or contains only spaces.`})
        return
      }
      dispatch(resetStore())
      dispatch(setSearchedValue(value))
      dispatch(requestProject())
      ajaxHelper.post(
        `/reverselookup/search`,
        {searchValue: value}
      ).then((response) => {
        if (response.data.errors) {
          dispatch(requestProjectFailure(`Could not load project (${response.data.errors})`))
        }else {
          const searchValue = response.data.searchValue
          dispatch(receiveProject(response.data))
          if ( response.data.id != '' && typeof response.data.id !== 'undefined' ) {
            dispatch(fetchDomain(searchValue, response.data.id))
            dispatch(fetchParents(searchValue, response.data.id))
            dispatch(fetchUsers(searchValue, response.data.id, response.data.searchBy))
            dispatch(fetchGroups(searchValue, response.data.id, response.data.searchBy))
          }
          handleSuccess()
        }
      }).catch(error => {
        dispatch(requestProjectFailure(`Could not load project (${error.message})`))
      })
    })
);

export {
  fetchProjectForm
}
