import { connect } from  'react-redux';
import ImageDetails from '../../components/images/details';
import { fetchBlobIfNeeded, fetchManifestsIfNeeded, fetchManifestIfNeeded } from '../../actions/keppel';

export default connect(
  (state, props) => {
    const { account: accountName, repo: repoName, digest } = props.match.params;
    const extraProps = {
      account:    (state.keppel.accounts.data || []).find(a => a.name == accountName),
      repository: { name: repoName },
      manifests:  (state.keppel.manifestsFor[accountName] || {})[repoName] || {},
      manifest:   ((state.keppel.manifestFor[accountName] || {})[repoName] || {})[digest] || {},
    };

    if (extraProps.manifest.data && extraProps.manifest.data.config) {
      const digest = extraProps.manifest.data.config.digest;
      extraProps.imageConfig = (state.keppel.blobFor[accountName] || {})[digest] || {};
    }

    return extraProps;
  },
  (dispatch, props) => {
    const { account: accountName, repo: repoName, digest } = props.match.params;
    return {
      loadManifestsOnce: ()           => dispatch(fetchManifestsIfNeeded(accountName, repoName)),
      loadManifestOnce:  ()           => dispatch(fetchManifestIfNeeded(accountName, repoName, digest)),
      loadBlobOnce:      (blobDigest) => dispatch(fetchBlobIfNeeded(accountName, repoName, blobDigest)),
    };
  },
)(ImageDetails);
