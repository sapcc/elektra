import { connect } from  'react-redux';
import EditShareNetworkModal from '../../components/share_networks/edit';
import { submitEditShareNetworkForm } from '../../actions/share_networks';

export default connect(
  (state,ownProps ) => {
    let shareNetwork;
    if (ownProps.match && ownProps.match.params && ownProps.match.params.id) {
      let shareNetworks = state.shareNetworks.items
      if (shareNetworks) shareNetwork = shareNetworks.find(item => item.id==ownProps.match.params.id)
    }
    return { shareNetwork }
  },
  dispatch => ({
    handleSubmit: (values) => dispatch(submitEditShareNetworkForm(values))
  })
)(EditShareNetworkModal);
