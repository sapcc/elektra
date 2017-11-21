import { connect } from  'react-redux';
import ShowShareModal from '../../components/share_networks/show';

const stateValues = function(state,shareNetworkId) {
  let isFetchingShareNetwork, isFetchingSubnet, isFetchingNetwork, shareNetwork, subnet, network;

  if (shareNetworkId && state.shareNetworks) {
    isFetchingShareNetwork = state.shareNetworks.isFetching
    shareNetwork = state.shareNetworks.items.find(item => item.id==shareNetworkId)
  }

  if (shareNetwork && state.subnets && state.subnets[shareNetwork.neutron_net_id]) {
    isFetchingSubnet = state.subnets[shareNetwork.neutron_net_id].isFetching
    subnet = state.subnets[shareNetwork.neutron_net_id].items.find((item) =>
      item.id==shareNetwork.neutron_subnet_id
    )
  }

  if (shareNetwork && state.networks) {
    isFetchingNetwork = state.networks.isFetching
    network = state.networks.items.find(item => item.id == shareNetwork.neutron_net_id)
  }

  return {
    isFetchingShareNetwork,
    isFetchingSubnet,
    isFetchingNetwork,
    shareNetwork,
    subnet,
    network
  }
}

export default connect(
  ({shared_filesystem_storage: state},ownProps ) => {
    let shareNetworkId = ((ownProps['match'] || {})['params'] || {})['id'];
    return stateValues(state,shareNetworkId)  
  },
  dispatch => ({})
)(ShowShareModal);
