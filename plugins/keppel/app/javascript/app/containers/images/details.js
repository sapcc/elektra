import { connect } from  'react-redux';
import ImageDetails from '../../components/images/details';
import { fetchManifestsIfNeeded, fetchManifestIfNeeded } from '../../actions/keppel';

export default connect(
  (state, props) => {
    const { account: accountName, repo: repoName, digest } = props.match.params;
    const accts = state.keppel.accounts;
    return {
      account:    (accts.data || []).find(a => a.name == accountName),
      repository: { name: repoName },
      manifests:  (state.keppel.manifestsFor[accountName] || {})[repoName] || {},
      manifest:   ((state.keppel.manifestFor[accountName] || {})[repoName] || {})[digest] || {},
    };
  },
  (dispatch, props) => {
    const { account: accountName, repo: repoName, digest } = props.match.params;
    return {
      loadManifestsOnce: () => dispatch(fetchManifestsIfNeeded(accountName, repoName)),
      loadManifestOnce:  () => dispatch(fetchManifestIfNeeded(accountName, repoName, digest)),
    };
  },
)(ImageDetails);
