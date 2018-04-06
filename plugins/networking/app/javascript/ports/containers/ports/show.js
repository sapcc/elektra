import { connect } from  'react-redux';
import Items from '../../components/ports/show';

import { fetchPortsIfNeeded } from '../../actions/ports';
import { fetchNetworksIfNeeded } from '../../actions/networks';
import { fetchSubnetsIfNeeded } from '../../actions/subnets';

export default connect(
  (state,ownProps ) => {
    let port;
    let match = ownProps.match
    if (match && match.params && match.params.id) {
      let ports = state.ports.items
      if (ports) port = ports.find(item => item.id==match.params.id)
    }

    return { port, networks: state.networks, subnets: state.subnets }
  },

  dispatch => ({
    loadPortsOnce: () => dispatch(fetchPortsIfNeeded()),
    loadNetworksOnce: () => dispatch(fetchNetworksIfNeeded()),
    loadSubnetsOnce: () => dispatch(fetchSubnetsIfNeeded())
  })
)(Items);
