import { connect } from  'react-redux';
import Roles from '../components/user_role_assignments';

import {fetchUserRoleAssignments} from '../actions/user_role_assignments'

export default connect(
  (state,ownProps ) => {
    let items;
    let isFetching;

    if (ownProps.userId) {
      const userRoleAssignments = state.role_assignments.user_role_assignments[ownProps.userId]
      if (userRoleAssignments && userRoleAssignments.items) {
        isFetching = userRoleAssignments.isFetching
        items = userRoleAssignments.items
      }
    }

    return { items, isFetching }
  },
  (dispatch, ownProps) => {
    return {
      loadUserRoleAssignments: () => dispatch(fetchUserRoleAssignments(ownProps.userId))
    }
  }
)(Roles);
