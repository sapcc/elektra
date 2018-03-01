import { connect } from  'react-redux';
import ShowSecurityServiceModal from '../../components/security_services/show';

export default connect(
  (state,ownProps ) => {
    let securityService, isFetching;
    let match = ownProps.match
    if (match && match.params && match.params.id) {
      isFetching = state.securityServices.isFetching;
      let securityServices = state.securityServices.items
      if (securityServices) securityService = securityServices.find(item => item.id==match.params.id)
    }
    
    return { isFetching, securityService }
  },
  dispatch => ({})
)(ShowSecurityServiceModal);
