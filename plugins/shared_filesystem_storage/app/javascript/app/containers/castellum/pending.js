import { connect } from  'react-redux';
import CastellumPendingOps from '../../components/castellum/pending';
import { fetchCastellumDataIfNeeded } from '../../actions/castellum';

const path = 'resources/nfs-shares/operations/pending';
export default connect(
  state => ({
    operations: (state.castellum || {})[path],
  }),
  dispatch => ({
    loadOpsOnce: (projectID) =>
      dispatch(fetchCastellumDataIfNeeded(projectID, path)),
  }),
)(CastellumPendingOps);
