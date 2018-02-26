import { connect } from  'react-redux';
import Items from '../../components/ports/list';
import {
  fetchPortsIfNeeded,
  deletePort,
  searchPorts,
  loadNext
} from '../../actions/ports'

export default connect(
  (state) => ({
    items: state.ports.items,
    isFetching: state.ports.isFetching,
    hasNext: state.ports.hasNext,
    searchTerm: state.ports.searchTerm
  }),

  dispatch => ({
    loadPortsOnce: () => dispatch(fetchPortsIfNeeded()),
    loadNext: () => dispatch(loadNext()),
    searchPorts: (term) => dispatch(searchPorts(term)),
    handleDelete: (portId) => dispatch(deletePort(portId))
  })
)(Items);
