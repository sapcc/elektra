import { connect } from  'react-redux';
import EditModal from '../../components/security_groups/edit';
import {
  submitEditSecurityGroupForm,
  fetchSecurityGroup
} from '../../actions/security_groups';

export default connect(
  (state,ownProps ) => {
    let securityGroup;
    let match = ownProps.match
    if (match && match.params && match.params.id) {
      let securityGroups = state.securityGroups.items
      if (securityGroups) securityGroup = securityGroups.find(i => i.id==match.params.id)
    }

    return {securityGroup}
  },
  (dispatch,ownProps) => {
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id
    return {
      handleSubmit: (values) => dispatch(submitEditSecurityGroupForm(id,values)),
      loadSecurityGroup: () => dispatch(fetchSecurityGroup(id))
    }
  }
)(EditModal);
