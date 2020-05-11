import { connect } from  'react-redux';
import AccountMaintenanceModal from '../../components/accounts/maintenance';
import { putAccount } from '../../actions/keppel';

export default connect(
  (state, props) => {
    const accountName = props.match.params.account;
    return {
      account: (state.keppel.accounts.data || []).find(a => a.name == accountName),
    };
  },
  dispatch => ({
    putAccount: (...args) => dispatch(putAccount(...args)),
  }),
)(AccountMaintenanceModal);
