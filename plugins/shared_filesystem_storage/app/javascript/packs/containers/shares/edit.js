import { connect } from  'react-redux';
import ShareEdit from '../../components/shares/edit';
import { submitEditShareForm } from '../../actions/shares';

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
        dispatch(submitEditShareForm(values,{handleSuccess,handleErrors}))
      )
    }
  )
)(ShareEdit);
