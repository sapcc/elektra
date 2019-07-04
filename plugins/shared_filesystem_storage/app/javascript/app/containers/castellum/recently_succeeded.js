import { connect } from  'react-redux';
import CastellumSucceededOps from '../../components/castellum/recently_succeeded';
import { fetchCastellumDataIfNeeded } from '../../actions/castellum';

const path = 'resources/nfs-shares/operations/recently-succeeded';
export default connect(
  state => ({
    operations: (state.castellum || {})[path],
  }),
  dispatch => ({
    loadOpsOnce: (projectID) =>
      dispatch(fetchCastellumDataIfNeeded(projectID, path)),
  }),
)(CastellumSucceededOps);
