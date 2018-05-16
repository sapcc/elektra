import { connect } from  'react-redux';
import Roles from '../components/roles';

import { fetchProjectRoles, updateProjectRoles } from '../actions/roles'

export default connect(
  (state,ownProps ) => {
    let roles;

    if (ownProps.project) {
      roles = state.role_assignments.project_roles[ownProps.project.id]
    }
    //console.log('roles',roles)
    return { roles }
  },
  dispatch => ({
    loadRoles: (projectId) => dispatch(fetchProjectRoles(projectId)),
    updateRoles: (projectId, roles) => dispatch(updateProjectRoles(projectId,roles))
  })
)(Roles);
