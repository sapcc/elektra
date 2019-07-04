import { connect } from  'react-redux';
import CastellumFailedOps from '../../components/castellum/recently_failed';
import { fetchCastellumDataIfNeeded } from '../../actions/castellum';

const path = 'resources/nfs-shares/operations/recently-failed';
export default connect(
  state => ({
    operations: (state.castellum || {})[path],
  }),
  dispatch => ({
    loadOpsOnce: (projectID) =>
      dispatch(fetchCastellumDataIfNeeded(projectID, path)),
  }),
)(CastellumFailedOps);
