import { connect } from  'react-redux';
import NewShareNetworForm from '../../components/share_networks/new';
import {
  fetchNetworksIfNeeded,
  fetchNetworkSubnetsIfNeeded,
  submitNewShareNetworkForm
} from '../../actions/share_networks';

export default connect(
  (state) => ({
    networks: state.networks,
    subnets: state.subnets
  }),

  dispatch => ({
    loadNetworksOnce: () => dispatch(fetchNetworksIfNeeded()),
    loadSubnetsOnce: (neutronNetworkId) => dispatch(fetchNetworkSubnetsIfNeeded(neutronNetworkId)),
    handleSubmit: (values) => dispatch(submitNewShareNetworkForm(values))
  })
)(NewShareNetworForm);
