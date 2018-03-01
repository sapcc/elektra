import { connect } from  'react-redux';
import SnapshotList from '../../components/snapshots/list';
import {
  fetchSnapshotsIfNeeded,
  deleteSnapshot,
  reloadSnapshot
} from '../../actions/snapshots';

export default connect(
  (state) => ({
    snapshots: state.snapshots.items,
    shares: state.shares,
    isFetching: state.snapshots.isFetching
  }),
  (dispatch) => ({
    loadSnapshotsOnce: () => dispatch(fetchSnapshotsIfNeeded()),
    handleDelete: (snapshotId) => dispatch(deleteSnapshot(snapshotId)),
    reloadSnapshot: (snapshotId) => dispatch(reloadSnapshot(snapshotId))
  })
)(SnapshotList)
