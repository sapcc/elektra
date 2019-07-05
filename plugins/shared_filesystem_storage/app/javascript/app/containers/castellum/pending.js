import { connect } from  'react-redux';
import CastellumOperationsList from '../../components/castellum/operations_list';
import { fetchCastellumDataIfNeeded } from '../../actions/castellum';

const path = 'resources/nfs-shares/operations/pending';
export default connect(
  state => ({
    jsonKey:    'pending_operations',
    operations: (state.castellum || {})[path],
  }),
  dispatch => ({
    loadOpsOnce: (projectID) =>
      dispatch(fetchCastellumDataIfNeeded(projectID, path)),
  }),
)(CastellumOperationsList);
