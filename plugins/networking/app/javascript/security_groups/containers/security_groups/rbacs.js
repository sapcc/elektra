import { connect } from "react-redux"
import RBACs from "../../components/security_groups/rbacs"

export default connect((state, ownProps) => {
  let securityGroup
  let securityGroupId =
    ownProps.match &&
    ownProps.match.params &&
    ownProps.match.params.securityGroupId

  if (securityGroupId) {
    securityGroup = state.securityGroups.items.find(
      (i) => i.id == securityGroupId
    )
  }

  return {
    securityGroup,
  }
})(RBACs)
