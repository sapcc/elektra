import { connect } from  'react-redux';
import NewShareModal from '../../components/shares/new';
import { submitNewShareForm } from '../../actions/shares'

export default connect(
  ({shared_filesystem_storage: state},ownProps ) => ({
    shareNetworks: state.shareNetworks,
    availabilityZones: state.availabilityZones
  }),
  dispatch => ({
    handleSubmit: (values) => dispatch(submitNewShareForm(values))
  })
)(NewShareModal);
