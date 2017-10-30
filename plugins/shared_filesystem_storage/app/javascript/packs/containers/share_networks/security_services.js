import { connect } from  'react-redux';
import SecurityServices from '../../components/share_networks/security_services';
import {
  submitShareNetworkSecurityServiceForm,
  fetchShareNetworkSecurityServicesIfNeeded,
  deleteShareNetworkSecurityService
} from '../../actions/share_network_security_services';

export default connect(
  ({shared_filesystem_storage: state},ownProps) => {
    let shareNetwork = state.shareNetworks.items.find(item => item.id==ownProps.match.params.id)
    let shareNetworkSecurityServices = {items: [], isFetching: false}
    if (shareNetwork && state.shareNetworkSecurityServices[shareNetwork.id]) {
      shareNetworkSecurityServices = state.shareNetworkSecurityServices[shareNetwork.id]
    }

    return {
      securityServices: state.securityServices.items,
      shareNetworkSecurityServices,
      shareNetwork
    }
  },

  (dispatch,ownProps) => ({
    loadShareNetworkSecurityServicesOnce: (shareNetworkId) => dispatch(fetchShareNetworkSecurityServicesIfNeeded(shareNetworkId)),
    handleSubmit: (values,{handleSuccess,handleErrors}) =>
      dispatch(submitShareNetworkSecurityServiceForm(values),{handleSuccess,handleErrors}),
    handleDelete: (shareNetworkId,securityServiceId) =>
      dispatch(deleteShareNetworkSecurityService(shareNetworkId,securityServiceId))
  })
)(SecurityServices);
