import { connect } from  'react-redux';
import EditForm from '../components/project_role_assignments_form';

import { updateProjectOwnerRoleAssignments } from '../actions/project_role_assignments'
import { fetchRolesIfNeeded } from '../actions/roles'

export default connect(
  state => (
    { availableRoles: state.role_assignments.roles }
  ),
  (dispatch, ownProps) => {
    let type = ownProps.ownerType.toLowerCase()

    return {
      updateProjectOwnerRoleAssignments: (projectId, ownerId, roles) => dispatch(updateProjectOwnerRoleAssignments(projectId,type,ownerId,roles)),
      loadRolesOnce: () => dispatch(fetchRolesIfNeeded())
    }
  }
)(EditForm);
