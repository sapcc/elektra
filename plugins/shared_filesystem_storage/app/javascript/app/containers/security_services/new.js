import { connect } from  'react-redux';
import NewSecurityServiceModal from '../../components/security_services/new';
import { submitNewSecurityServiceForm } from '../../actions/security_services';

export default connect(
  (state ) => ({}),
  dispatch => ({
    handleSubmit: (values) => dispatch(submitNewSecurityServiceForm(values))
  })
)(NewSecurityServiceModal);
