import { connect } from  'react-redux';
import ShareNew from '../../components/shares/new';
import { submitNewShareForm } from '../../actions/shares';

export default connect(
  state => (
    {
      shareNetworks: state.shared_filesystem_storage.shareNetworks,
      availabilityZones: state.shared_filesystem_storage.availabilityZones
    }
  ),
  (dispatch) => (
    {
      handleSubmit: (values,{handleSuccess,handleErrors}) => (
        dispatch(submitNewShareForm(values,{handleSuccess,handleErrors}))
      )
    }
  )
)(ShareNew);
