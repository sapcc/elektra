import { connect } from  'react-redux';
import AccountList from '../../components/accounts/list';

export default connect(
  state => ({
    accounts: state.keppel.accounts.data || [],
  }),
)(AccountList);
