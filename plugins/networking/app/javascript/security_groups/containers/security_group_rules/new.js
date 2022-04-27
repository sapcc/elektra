import { connect } from  'react-redux';
import NewModal from '../../components/security_group_rules/new';
import {
  fetchSecurityGroupsIfNeeded,
  fetchSecurityGroup
} from '../../actions/security_groups'

import {
  submitNewSecurityGroupRuleForm
} from '../../actions/security_group_rules'

export default connect(
  (state,ownProps ) => {
    let securityGroup
    let securityGroupId = ownProps.match && ownProps.match.params && ownProps.match.params.securityGroupId

    if(securityGroupId)  {
      securityGroup = state.securityGroups.items.find(i => i.id==securityGroupId)
    }

    return {
      securityGroupId,
      securityGroup,
      securityGroups: state.securityGroups
    }
  },
  (dispatch,ownProps) => {
    let securityGroupId = ownProps.match && ownProps.match.params && ownProps.match.params.securityGroupId
    return {
      loadSecurityGroupsOnce: () => dispatch(fetchSecurityGroupsIfNeeded()),
      handleSubmit: (values) => dispatch(submitNewSecurityGroupRuleForm(securityGroupId, values)),
      loadSecurityGroup: () => securityGroupId ? dispatch(fetchSecurityGroup(securityGroupId)) : null
    }
  }
)(NewModal);
