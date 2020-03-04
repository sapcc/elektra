import { connect } from  'react-redux';
import Loader from '../components/loader';
import { fetchAccountsIfNeeded, fetchPeersIfNeeded } from '../actions/keppel';

const interpret = ({ requestedAt, isFetching, data }) => ({
  isFetching: isFetching || requestedAt === null,
  isLoaded:   data !== null,
});

export default connect(
  state => {
    const accountsState = interpret(state.keppel.accounts);
    const peersState = interpret(state.keppel.peers);
    return {
      isFetching: accountsState.isFetching || peersState.isFetching,
      isLoaded:   accountsState.isLoaded   && peersState.isLoaded,
    };
  },
  dispatch => ({
    loadAccountsOnce: (...args) => dispatch(fetchAccountsIfNeeded(...args)),
    loadPeersOnce:    (...args) => dispatch(fetchPeersIfNeeded(...args)),
  }),
)(Loader);
