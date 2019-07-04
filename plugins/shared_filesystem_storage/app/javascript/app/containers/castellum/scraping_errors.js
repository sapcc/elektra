import { connect } from  'react-redux';
import CastellumScrapingErrors from '../../components/castellum/scraping_errors';
import { fetchCastellumDataIfNeeded } from '../../actions/castellum';

const path = 'assets/nfs-shares';
export default connect(
  state => ({
    assets: (state.castellum || {})[path],
  }),
  dispatch => ({
    loadAssetsOnce: (projectID) =>
      dispatch(fetchCastellumDataIfNeeded(projectID, path)),
  }),
)(CastellumScrapingErrors);
