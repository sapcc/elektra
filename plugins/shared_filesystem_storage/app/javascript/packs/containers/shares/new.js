import { connect } from  'react-redux';
import ShareNew from '../../components/shares/new';
import { updateShareForm, submitShareForm, shareFormForCreate} from '../../actions/shares'

export default connect(
  state => ((pluginState) => ({
    shareForm: pluginState.shareForm,
    shareNetworks: pluginState.shareNetworks,
    availabilityZones: pluginState.availabilityZones,
  }))(state.shared_filesystem_storage),

  (dispatch, ownProps) => {
    console.log(ownProps)
    if(ownProps.show) dispatch(shareFormForCreate())
    return {
      handleChange: (name,value) => dispatch(updateShareForm(name,value)),
      handleSubmit: (callback) => dispatch(submitShareForm(callback))
    }
  }
)(ShareNew);
