import { connect } from  'react-redux';
import NewModal from '../../components/security_group_rules/new';
import {
  fetchSecurityGroup
} from '../../actions/security_groups'

import {
  submitNewRuleForm
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
      securityGroup
    }
  },
  dispatch => ({
    handleSubmit: (values) => dispatch(submitNewRuleForm(values)),
    loadSecurityGroup: () => dispatch(fetchSecurityGroup(securityGroupId))
  })
)(NewModal);
