import { connect } from "react-redux"
import Items from "../../components/security_groups/list"
import {
  fetchSecurityGroupsIfNeeded,
  deleteSecurityGroup,
} from "../../actions/security_groups"

export default connect(
  (state) => ({
    securityGroups: state.securityGroups,
  }),

  (dispatch) => ({
    loadSecurityGroupsOnce: () => dispatch(fetchSecurityGroupsIfNeeded()),
    handleDelete: (id) => dispatch(deleteSecurityGroup(id)),
  })
)(Items)
