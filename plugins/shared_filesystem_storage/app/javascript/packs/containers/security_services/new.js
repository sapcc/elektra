import { connect } from  'react-redux';
import NewSecurityServiceModal from '../../components/security_services/new';
import { submitNewSecurityServiceForm } from '../../actions/security_services';

export default connect(
  ({shared_filesystem_storage:state} ) => ({}),
  dispatch => ({
    handleSubmit: (values,{handleSuccess,handleErrors}) =>
      dispatch(submitNewSecurityServiceForm(values,{handleSuccess,handleErrors}))
  })
)(NewSecurityServiceModal);
