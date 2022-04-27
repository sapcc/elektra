import { connect } from  'react-redux';
import AccountSubleaseTokenModal from '../../components/accounts/sublease';
import { getAccountSubleaseToken } from '../../actions/keppel';

export default connect(
  (state, props) => {
    const accountName = props.match.params.account;
    return {
      account: (state.keppel.accounts.data || []).find(a => a.name == accountName),
    };
  },
  dispatch => ({
    getAccountSubleaseToken: (...args) => dispatch(getAccountSubleaseToken(...args)),
  }),
)(AccountSubleaseTokenModal);
