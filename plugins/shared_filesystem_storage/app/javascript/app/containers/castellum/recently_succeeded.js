import { connect } from  'react-redux';
import CastellumOperationsList from '../../components/castellum/operations_list';
import { fetchCastellumDataIfNeeded } from '../../actions/castellum';

const path = 'resources/nfs-shares/operations/recently-succeeded';
export default connect(
  state => ({
    operations: (state.castellum || {})[path],
  }),
  dispatch => ({
    loadOpsOnce: (projectID) =>
      dispatch(fetchCastellumDataIfNeeded(projectID, path, 'recently_succeeded_operations')),
  }),
)(CastellumOperationsList);
