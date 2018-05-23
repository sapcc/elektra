import { connect } from  'react-redux';
import Roles from '../components/project_user_roles';

import {
  fetchProjectUserRoles,
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
    //console.log('roles',roles)
    console.log('projectUserRoles',projectUserRoles)
    return { projectUserRoles, roles: state.role_assignments.roles }
  },
  dispatch => ({
    loadProjectUserRoles: (projectId) => dispatch(fetchProjectUserRoles(projectId)),
    updateProjectUserRoles: (projectId, userId, roles) => dispatch(updateProjectUserRoles(projectId,userId,roles)),
    loadRolesOnce: () => dispatch(fetchRolesIfNeeded())
  })
)(Roles);
