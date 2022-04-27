import { connect } from  'react-redux';
import Loader from '../components/loader';
import { fetchAccountsIfNeeded } from '../actions/keppel';

export default connect(
  state => {
    const { requestedAt, isFetching, data } = state.keppel.accounts;
    return {
      isFetching: isFetching || requestedAt === null,
      isLoaded:   data !== null,
    };
  },
  dispatch => ({
    loadAccountsOnce: (...args) => dispatch(fetchAccountsIfNeeded(...args)),
  }),
)(Loader);
