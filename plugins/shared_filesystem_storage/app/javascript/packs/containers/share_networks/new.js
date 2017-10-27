import { connect } from  'react-redux';
import NewShareNetworForm from '../../components/share_networks/new';
import {
  fetchNetworksIfNeeded,
  fetchNetworkSubnetsIfNeeded,
  submitNewShareNetworkForm
} from '../../actions/share_networks';

export default connect(
  ({shared_filesystem_storage: state}) => ({
    networks: state.networks,
    subnets: state.subnets
  }),

  dispatch => ({
    loadNetworksOnce: () => dispatch(fetchNetworksIfNeeded()),
    loadSubnetsOnce: (neutronNetworkId) => dispatch(fetchNetworkSubnetsIfNeeded(neutronNetworkId)),
    handleSubmit: (values,{handleSuccess,handleErrors}) => (
      dispatch(submitNewShareNetworkForm(values,{handleSuccess,handleErrors}))
    )
  })
)(NewShareNetworForm);
