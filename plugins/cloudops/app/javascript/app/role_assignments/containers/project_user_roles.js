import { connect } from  'react-redux';
import Roles from '../components/project_user_roles';

import {
  fetchProjectRoles,
  updateProjectUserRoles
} from '../actions/project_user_roles'

import {
  fetchRolesIfNeeded
} from '../actions/roles'

export default connect(
  (state,ownProps ) => {
    let projectUserRoles;

    if (ownProps.project) {
      projectUserRoles = state.role_assignments.project_user_roles[ownProps.project.id]
    }

    return { projectUserRoles, roles: state.role_assignments.roles }
  },
  dispatch => ({
    loadProjectRoles: (projectId) => dispatch(fetchProjectRoles(projectId)),
    updateProjectUserRoles: (projectId, userId, roles) => dispatch(updateProjectUserRoles(projectId,userId,roles)),
    loadRolesOnce: () => dispatch(fetchRolesIfNeeded())
  })
)(Roles);
