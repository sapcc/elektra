import { connect } from  'react-redux';
import ShareNew from '../../components/shares/new';
import { updateShareForm, submitShareForm, shareFormForCreate} from '../../actions/shares'

export default connect(
  state => (
    {
      shareForm: state.shared_filesystem_storage.shareForm,
      shareNetworks: state.shared_filesystem_storage.shareNetworks,
      availabilityZones: state.shared_filesystem_storage.availabilityZones
    }
  ),
  (dispatch) => (
    {
      handleChange: (name,value) => dispatch(updateShareForm(name,value)),
      handleSubmit: (callback) => dispatch(submitShareForm(callback))
    }
  )
)(ShareNew);
