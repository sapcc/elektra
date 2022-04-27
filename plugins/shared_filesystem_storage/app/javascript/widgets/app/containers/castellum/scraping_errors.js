import { connect } from  'react-redux';
import CastellumScrapingErrors from '../../components/castellum/scraping_errors';
import { fetchCastellumDataIfNeeded } from '../../actions/castellum';
import { deleteShare, forceDeleteShare } from '../../actions/shares';

const path = 'assets/nfs-shares';
export default connect(
  state => ({
    assets: (state.castellum || {})[path],
    shares: (state.shares || {}).items,
  }),
  dispatch => ({
    loadAssetsOnce: (projectID) =>
      dispatch(fetchCastellumDataIfNeeded(projectID, path)),
    handleDelete:      (shareID) => dispatch(deleteShare(shareID)),
    handleForceDelete: (shareID) => dispatch(forceDeleteShare(shareID))
  }),
)(CastellumScrapingErrors);
