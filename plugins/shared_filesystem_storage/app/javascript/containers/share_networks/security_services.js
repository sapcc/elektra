import { connect } from  'react-redux';
import SecurityServices from '../../components/share_networks/security_services';
import {
  submitShareNetworkSecurityServiceForm,
  fetchShareNetworkSecurityServicesIfNeeded,
  deleteShareNetworkSecurityService
} from '../../actions/share_network_security_services';

export default connect(
  (state,ownProps) => {
    let shareNetwork = state.shareNetworks.items.find(item => item.id==ownProps.match.params.id)
    let shareNetworkSecurityServices = null;
    if(shareNetwork) {
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
    handleSubmit: (values) =>
      dispatch(submitShareNetworkSecurityServiceForm(
        Object.assign(values,{shareNetworkId: ownProps.match.params.id}))
      )
    ,
    handleDelete: (securityServiceId) => {
      dispatch(deleteShareNetworkSecurityService(ownProps.match.params.id,securityServiceId))
    }
  })
)(SecurityServices);
