import { connect } from  'react-redux';
import EditForm from '../components/project_user_roles_edit_form';

import { updateProjectUserRoles } from '../actions/project_user_roles'
import { fetchRolesIfNeeded } from '../actions/roles'

export default connect(
  state => (
    { availableRoles: state.role_assignments.roles }
  ),
  dispatch => ({
    updateProjectUserRoles: (projectId, userId, roles) => dispatch(updateProjectUserRoles(projectId,userId,roles)),
    loadRolesOnce: () => dispatch(fetchRolesIfNeeded())
  })
)(EditForm);
