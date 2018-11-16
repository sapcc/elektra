import { connect } from  'react-redux';
import Items from '../../components/ports/show';

import { fetchPort } from '../../actions/ports';
import { fetchNetworksIfNeeded } from '../../actions/networks';
import { fetchSubnetsIfNeeded } from '../../actions/subnets';
import { fetchSecurityGroupsIfNeeded } from '../../actions/security_groups';

export default connect(
  (state,ownProps ) => {
    let port;
    let match = ownProps.match
    if (match && match.params && match.params.id) {
      let ports = state.ports.items
      if (ports) port = ports.find(item => item.id==match.params.id)
    }

    return {
      port,
      networks: state.networks,
      subnets: state.subnets,
      securityGroups: state.securityGroups
    }
  },

  (dispatch,ownProps) => {
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id 
    return {
      loadSecurityGroupsOnce: () => dispatch(fetchSecurityGroupsIfNeeded()),
      loadPort: () => dispatch(fetchPort(id)),
      loadNetworksOnce: () => dispatch(fetchNetworksIfNeeded()),
      loadSubnetsOnce: () => dispatch(fetchSubnetsIfNeeded())
    }
  }
)(Items);
