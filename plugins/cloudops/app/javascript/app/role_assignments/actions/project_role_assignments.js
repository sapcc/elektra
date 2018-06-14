import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice as showNotice, addError as showError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

//################### OBJECTS #########################
const requestProjectRoleAssignments= (projectId) => (
  {
    type: constants.REQUEST_PROJECT_ROLE_ASSIGNMENTS,
    requestedAt: Date.now(),
    projectId
  }
);

const requestProjectRoleAssignmentsFailure= (projectId) => (
  {
    type: constants.REQUEST_PROJECT_ROLE_ASSIGNMENTS_FAILURE,
    projectId
  }
);

const receiveProjectRoleAssignments= (projectId, roles) => (
  {
    type: constants.RECEIVE_PROJECT_ROLE_ASSIGNMENTS,
    receivedAt: Date.now(),
    projectId,
    roles
  }
);

const receiveProjectOwnerRoleAssignments= (projectId, ownerType, ownerId, roles) => (
  {
    type: constants.RECEIVE_PROJECT_OWNER_ROLE_ASSIGNMENTS,
    projectId,
    ownerType,
    ownerId,
    roles
  }
);

const fetchProjectRoleAssignments = (projectId) =>
  (dispatch,getState) => {
    const projectRoleAssignments = getState()['role_assignments']['project_role_assignments']
    if (projectRoleAssignments && projectRoleAssignments[projectId] &&
        projectRoleAssignments[projectId].isFetching) return
    dispatch(requestProjectRoleAssignments(projectId));
    ajaxHelper.get(`/role_assignments?scope_project_id=${projectId}`).then( (response) => {
      dispatch(receiveProjectRoleAssignments(projectId, response.data.roles));
    })
    .catch( (error) => {
      dispatch(requestProjectRoleAssignmentsFailure());
      showError(`Could not load project role assignments (${error.message})`)
    });
  }
;

const updateProjectOwnerRoleAssignments = (projectId, ownerType, ownerId, roles) =>
  (dispatch) => {
    const data = {scope_project_id: projectId, roles}
    data[`${ownerType}_id`] = ownerId

    return ajaxHelper.put(
      '/role_assignments', data
    ).then((response) => dispatch(receiveProjectOwnerRoleAssignments(
      projectId, ownerType, ownerId, response.data.roles)
    ))
  }

export {
  fetchProjectRoleAssignments,
  updateProjectOwnerRoleAssignments
}
