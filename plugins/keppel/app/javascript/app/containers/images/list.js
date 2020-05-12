import { connect } from  'react-redux';
import ImageList from '../../components/images/list';
import { deleteManifest, fetchManifestsIfNeeded } from '../../actions/keppel';

export default connect(
  (state, props) => {
    const { account: accountName, repo: repoName } = props.match.params;
    const accts = state.keppel.accounts;
    return {
      account:    (accts.data || []).find(a => a.name == accountName),
      repository: { name: repoName },
      manifests:  (state.keppel.manifestsFor[accountName] || {})[repoName] || {},
    };
  },
  (dispatch, props) => {
    const { account: accountName, repo: repoName } = props.match.params;
    return {
      loadManifestsOnce:     () => dispatch(fetchManifestsIfNeeded(accountName, repoName)),
      deleteManifest: (...args) => dispatch(deleteManifest(accountName, repoName, ...args)),
    };
  },
)(ImageList);
