import { connect } from  'react-redux';
import ImageList from '../../components/images/list';
import { deleteManifest, deleteTag, fetchManifestsIfNeeded } from '../../actions/keppel';

const fixGreedyRepoNameMatch = (repoName) => {
  //In the <Route> to this component, we match on `/repo/:account/:repo+`. This
  //will match too much if there is a subpath behind the repo. For example, the
  //path `/repo/foo/bar/baz/-/manifests/sha256:12345/details` would match as
  //
  //  account = "foo"                           # correct
  //  repo = "bar/baz/-/manifests/sha256:12345" # should be "bar/baz"
  //
  //Since the repo name can legitimately contain slahes, we would have to do
  //some high-level regex trickery to get this match correct in the <Route/>.
  //A much simpler solution is this hack right here: We match everything first,
  //then cut off a subpath introduced by `/-/`, if any. (A single dash is not a
  //valid path element in a repo name.)
  return repoName.split("/-/")[0];
};

export default connect(
  (state, props) => {
    const { account: accountName, repo: repoNameMatch } = props.match.params;
    const repoName = fixGreedyRepoNameMatch(repoNameMatch);
    const accts = state.keppel.accounts;
    return {
      account:    (accts.data || []).find(a => a.name == accountName),
      repository: { name: repoName },
      manifests:  (state.keppel.manifestsFor[accountName] || {})[repoName] || {},
    };
  },
  (dispatch, props) => {
    const { account: accountName, repo: repoNameMatch } = props.match.params;
    const repoName = fixGreedyRepoNameMatch(repoNameMatch);
    return {
      loadManifestsOnce:     () => dispatch(fetchManifestsIfNeeded(accountName, repoName)),
      deleteManifest: (...args) => dispatch(deleteManifest(accountName, repoName, ...args)),
      deleteTag:      (...args) => dispatch(deleteTag(accountName, repoName, ...args)),
    };
  },
)(ImageList);
