import { connect } from  'react-redux';
import RepositoryList from '../../components/repositories/list';
import { fetchRepositoriesIfNeeded } from '../../actions/keppel';

export default connect(
  (state, props) => {
    const accountName = props.match.params.account;
    const accts = state.keppel.accounts;
    return {
      account: (accts.data || []).find(a => a.name == accountName),
      repos: state.keppel.repositoriesFor[accountName] || {},
    };
  },
  dispatch => ({
    loadRepositoriesOnce: (...args) => dispatch(fetchRepositoriesIfNeeded(...args)),
  }),
)(RepositoryList);
