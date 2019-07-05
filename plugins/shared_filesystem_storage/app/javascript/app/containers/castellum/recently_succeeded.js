import { connect } from  'react-redux';
import CastellumOperationsList from '../../components/castellum/operations_list';
import { fetchCastellumDataIfNeeded } from '../../actions/castellum';
import { deleteShare, forceDeleteShare } from '../../actions/shares';

const path = 'resources/nfs-shares/operations/recently-succeeded';
export default connect(
  state => ({
    operations: (state.castellum || {})[path],
    shares:     (state.shares || {}).items,
  }),
  dispatch => ({
    loadOpsOnce: (projectID) =>
      dispatch(fetchCastellumDataIfNeeded(projectID, path, 'recently_succeeded_operations')),
    handleDelete:      (shareID) => dispatch(deleteShare(shareID)),
    handleForceDelete: (shareID) => dispatch(forceDeleteShare(shareID))
  }),
)(CastellumOperationsList);
