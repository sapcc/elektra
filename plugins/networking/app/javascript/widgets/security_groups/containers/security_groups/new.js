import { connect } from  'react-redux';
import NewModal from '../../components/security_groups/new';
import {
  submitNewSecurityGroupForm,
  fetchSecurityGroupsIfNeeded
} from '../../actions/security_groups'

export default connect(
  (state,ownProps ) => ({
  }),
  dispatch => ({
    handleSubmit: (values) => dispatch(submitNewSecurityGroupForm(values))
  })
)(NewModal);
