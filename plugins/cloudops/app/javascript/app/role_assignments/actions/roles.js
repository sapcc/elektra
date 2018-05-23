import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice as showNotice, addError as showError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

//################### OBJECTS #########################
const requestRoles= () => (
  {
    type: constants.REQUEST_ROLES,
    requestedAt: Date.now()
  }
);

const requestRolesFailure= () => (
  {
    type: constants.REQUEST_ROLES_FAILURE
  }
);

const receiveRoles= (roles) => (
  {
    type: constants.RECEIVE_ROLES,
    receivedAt: Date.now(),
    roles
  }
);

const fetchRoles = () =>
  (dispatch) => {
    dispatch(requestRoles());
    ajaxHelper.get('/role_assignments/available_roles').then( (response) => {
      dispatch(receiveRoles(response.data.roles));
    })
    .catch( (error) => {
      dispatch(requestRolesFailure());
      showError(`Could not load roles (${error.message})`)
    });
  }
;

const shouldFetchRoles= function(state) {
  const { roles } = state.role_assignments;
  if (roles.isFetching || roles.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchRolesIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchRoles(getState())) { return dispatch(fetchRoles()); }
  }
;

export {
  fetchRolesIfNeeded
}
