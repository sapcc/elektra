import { connect } from  'react-redux';
import SecurityServiceList from '../../components/security_services/list';
import {fetchSecurityServicesIfNeeded, deleteSecurityService } from '../../actions/security_services';

export default connect(
  ({shared_filesystem_storage:state}) => ({
    securityServices: state.securityServices.items,
    isFetching: state.securityServices.isFetching
  }),

  (dispatch) => ({
    loadSecurityServicesOnce: () => dispatch(fetchSecurityServicesIfNeeded()),
    handleDelete: (securityServiceId) => dispatch(deleteSecurityService(securityServiceId))
  })
)(SecurityServiceList)
