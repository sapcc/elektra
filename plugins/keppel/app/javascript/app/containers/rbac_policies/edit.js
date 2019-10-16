import { connect } from  'react-redux';
import RBACPoliciesEditModal from '../../components/rbac_policies/edit';
import { putAccount } from '../../actions/keppel';

export default connect(
  (state, props) => {
    const accountName = props.match.params.account;
    const accts = state.keppel.accounts;
    return {
      account: (accts.data || []).find(a => a.name == accountName),
      isFetching: accts.isFetching,
    };
  },
  dispatch => ({
    putAccount: (...args) => dispatch(putAccount(...args)),
  }),
)(RBACPoliciesEditModal);
