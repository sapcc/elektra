import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice as showNotice, addError as showError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

//################### OBJECTS #########################
const requestProjectUserRoles= (projectId) => (
  {
    type: constants.REQUEST_PROJECT_USER_ROLES,
    requestedAt: Date.now(),
    projectId
  }
);

const requestProjectUserRolesFailure= (projectId) => (
  {
    type: constants.REQUEST_PROJECT_USER_ROLES_FAILURE,
    projectId
  }
);

const receiveProjectUserRoles= (projectId, roles) => (
  {
    type: constants.RECEIVE_PROJECT_USER_ROLES,
    receivedAt: Date.now(),
    projectId,
    roles
  }
);

const fetchProjectUserRoles = (projectId) =>
  (dispatch) => {
    dispatch(requestProjectUserRoles(projectId));
    ajaxHelper.get(`/role_assignments?scope_project_id=${projectId}`).then( (response) => {
      dispatch(receiveProjectUserRoles(projectId, response.data.roles));
    })
    .catch( (error) => {
      dispatch(requestProjectUserRolesFailure());
      showError(`Could not load project roles (${error.message})`)
    });
  }
;

const updateProjectUserRoles = (projectId, userId, roles) => {}

export {
  fetchProjectUserRoles,
  updateProjectUserRoles
}
