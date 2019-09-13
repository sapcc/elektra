import { connect } from  'react-redux';
import AccountList from '../../components/accounts/list';
import { fetchAccountsIfNeeded } from '../../actions/keppel';

export default connect(
  (state, props) => ({
    accounts:   state.keppel.accounts.data || [],
    isFetching: state.keppel.accounts.isFetching,
  }),
  dispatch => ({
    loadAccountsOnce: (...args) => dispatch(fetchAccountsIfNeeded(...args)),
  }),
)(AccountList);
