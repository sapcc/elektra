import { connect } from  'react-redux';
import ManifestList from '../../components/manifests/list';
import { fetchManifestsIfNeeded } from '../../actions/keppel';

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
  dispatch => ({
    loadManifestsOnce: (...args) => dispatch(fetchManifestsIfNeeded(...args)),
  }),
)(ManifestList);
