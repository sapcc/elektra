import { connect } from  'react-redux';
import NewShareModal from '../../components/ports/new';
import { submitNewPortForm } from '../../actions/ports';
import { fetchNetworksIfNeeded } from '../../actions/networks';
import { fetchSubnetsIfNeeded } from '../../actions/subnets';
import { fetchSecurityGroupsIfNeeded } from '../../actions/security_groups';

export default connect(
  (state,ownProps ) => ({
    networks: state.networks,
    subnets: state.subnets,
    securityGroups: state.securityGroups
  }),
  dispatch => ({
    handleSubmit: (values) => dispatch(submitNewPortForm(values)),
    loadSecurityGroupsOnce: () => dispatch(fetchSecurityGroupsIfNeeded()),
    loadNetworksOnce: () => dispatch(fetchNetworksIfNeeded()),
    loadSubnetsOnce: () => dispatch(fetchSubnetsIfNeeded())
  })
)(NewShareModal);
