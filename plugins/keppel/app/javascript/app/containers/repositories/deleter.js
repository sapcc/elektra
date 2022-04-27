import { connect } from  'react-redux';
import RepositoryDeleter from '../../components/repositories/deleter';
import {
  deleteManifest,
  deleteRepository,
  fetchManifestsIfNeeded,
} from '../../actions/keppel';

export default connect(
  (state, props) => {
    const { accountName, repoName } = props;
    return {
      manifests: (state.keppel.manifestsFor[accountName] || {})[repoName] || {},
    };
  },
  (dispatch, props) => {
    const { accountName, repoName } = props;
    dispatch(fetchManifestsIfNeeded(accountName, repoName));
    return {
      deleteManifest: (digest) => dispatch(deleteManifest(accountName, repoName, digest, null)),
      deleteRepository:     () => dispatch(deleteRepository(accountName, repoName)),
    };
  },
)(RepositoryDeleter);
