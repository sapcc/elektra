import { connect } from  'react-redux';
import NewShareModal from '../../components/shares/new';
import { submitNewShareForm } from '../../actions/shares';
import { fetchShareTypesIfNeeded } from '../../actions/share_types';

export default connect(
  (state,ownProps ) => ({
    shareNetworks: state.shareNetworks,
    availabilityZones: state.availabilityZones,
    shareTypes: state.shareTypes
  }),
  dispatch => ({
    handleSubmit: (values) => dispatch(submitNewShareForm(values)),
    loadShareTypesOnce: () => dispatch(fetchShareTypesIfNeeded())
  })
)(NewShareModal);
