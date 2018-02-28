import { connect } from  'react-redux';
import Items from '../../components/ports/list';
import {
  fetchPortsIfNeeded,
  deletePort,
  searchPorts,
  loadNext
} from '../../actions/ports';

import { fetchNetworksIfNeeded } from '../../actions/networks';
import { fetchSubnetsIfNeeded } from '../../actions/subnets';

export default connect(
  (state) => (
    {
      items: state.ports.items,
      networks: state.networks,
      subnets: state.subnets,
      isFetching: state.ports.isFetching,
      hasNext: state.ports.hasNext,
      searchTerm: state.ports.searchTerm
    }
  ),

  dispatch => ({
    loadPortsOnce: () => dispatch(fetchPortsIfNeeded()),
    loadNetworksOnce: () => dispatch(fetchNetworksIfNeeded()),
    loadSubnetsOnce: () => dispatch(fetchSubnetsIfNeeded()),
    loadNext: () => dispatch(loadNext()),
    searchPorts: (term) => dispatch(searchPorts(term)),
    handleDelete: (portId) => dispatch(deletePort(portId))
  })
)(Items);
