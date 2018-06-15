import { connect } from  'react-redux';
import Roles from '../components/project_role_assignments';

import {
  fetchProjectRoleAssignments,
  updateProjectMemberRoleAssignments
} from '../actions/project_role_assignments'

import {
  fetchRolesIfNeeded
} from '../actions/roles'

export default connect(
  (state,ownProps ) => {
    let items;
    let isFetching;
    let type = ownProps.type.toLowerCase()

    if (ownProps.project) {
      const projectRoleAssignments = state.role_assignments.project_role_assignments[ownProps.project.id]
      if (projectRoleAssignments && projectRoleAssignments.items) {
        isFetching = projectRoleAssignments.isFetching
        items = projectRoleAssignments.items.filter(i => i.hasOwnProperty(type) )
      }
    }

    return { items, isFetching, roles: state.role_assignments.roles, type }
  },
  (dispatch, ownProps) => {
    let type = ownProps.type.toLowerCase()

    return {
      loadProjectRoleAssignments: (projectId) => dispatch(fetchProjectRoleAssignments(projectId)),
      updateProjectMemberRoleAssignments: (projectId, memberId, roles) =>
        dispatch(updateProjectMemberRoleAssignments(projectId,type, memberId,roles)),
      loadRolesOnce: () => dispatch(fetchRolesIfNeeded())
    }
  }
)(Roles);
