import { connect } from  'react-redux';
import ShareList from '../../components/share_networks/list';
import {
  fetchShareNetworksIfNeeded,
  //fetchSecurityServicesIfNeeded,
  fetchNetworksIfNeeded,
  fetchNetworkSubnetsIfNeeded,
  deleteShareNetwork,
  submitNewShareNetworkForm
} from '../../actions/share_networks';

export default connect(
  ({shared_filesystem_storage: state}) => ({
    shareNetworks: state.shareNetworks.items,
    isFetching: state.shareNetworks.isFetching,
    networks: state.networks,
    subnets: state.subnets
  }),

  dispatch => ({
    loadShareNetworksOnce: () => dispatch(fetchShareNetworksIfNeeded()),
    loadSecurityServicesOnce: () => null,//dispatch(fetchSecurityServicesIfNeeded()),
    loadNetworksOnce: () => dispatch(fetchNetworksIfNeeded()),
    loadSubnetsOnce: (neutronNetworkId) => dispatch(fetchNetworkSubnetsIfNeeded(neutronNetworkId)),
    handleDelete: (shareNetworkId) => dispatch(deleteShareNetwork(shareNetworkId)),
    handleSubmitNew: (values,{handleSuccess,handleErrors}) => (
      dispatch(submitNewShareNetworkForm(values,{handleSuccess,handleErrors}))
    )
  })
)(ShareList);
