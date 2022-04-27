import { connect } from  'react-redux';
import AccountDeleter from '../../components/accounts/deleter';
import { deleteAccount, deleteManifest } from '../../actions/keppel';

export default connect(
  (state, props) => {
    const { accountName } = props;
    const accts = state.keppel.accounts;
    return {
      account: (accts.data || []).find(a => a.name == accountName),
    };
  },
  (dispatch, props) => {
    const { accountName } = props;
    return {
      deleteAccount:  ()                 => dispatch(deleteAccount(accountName)),
      deleteManifest: (repoName, digest) => dispatch(deleteManifest(accountName, repoName, digest, null)),
    };
  },
)(AccountDeleter);
