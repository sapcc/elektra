import { connect } from "react-redux"
import RoleInfos from "../components/RoleInfos"
import { fetchRolesIfNeeded } from "../actions/roles"

export default connect(
  (state, ownProps) => ({
    isFetching: state.role_assignments.roles.isFetching,
    items: state.role_assignments.roles.items,
  }),
  (dispatch, ownProps) => {
    return {
      loadRoles: () => dispatch(fetchRolesIfNeeded()),
    }
  }
)(RoleInfos)
