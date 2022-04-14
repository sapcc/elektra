import { connect } from  'react-redux';
import ShareList from '../../components/share_networks/list';
import { fetchSecurityServicesIfNeeded } from '../../actions/security_services';
import {
  fetchShareNetworksIfNeeded,
  fetchNetworksIfNeeded,
  fetchNetworkSubnetsIfNeeded,
  deleteShareNetwork,
  submitNewShareNetworkForm
} from '../../actions/share_networks';

export default connect(
  (state) => ({
    shareNetworks: state.shareNetworks.items,
    isFetching: state.shareNetworks.isFetching,
    networks: state.networks,
    subnets: state.subnets
  }),

  dispatch => ({
    loadShareNetworksOnce: () => dispatch(fetchShareNetworksIfNeeded()),
    loadSecurityServicesOnce: () => dispatch(fetchSecurityServicesIfNeeded()),
    loadNetworksOnce: () => dispatch(fetchNetworksIfNeeded()),
    loadSubnetsOnce: (neutronNetworkId) => dispatch(fetchNetworkSubnetsIfNeeded(neutronNetworkId)),
    handleDelete: (shareNetworkId) => dispatch(deleteShareNetwork(shareNetworkId)),
    handleSubmitNew: (values,{handleSuccess,handleErrors}) => (
      dispatch(submitNewShareNetworkForm(values,{handleSuccess,handleErrors}))
    )
  })
)(ShareList);
