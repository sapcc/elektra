import { connect } from  'react-redux';
import SnapshotList from '../../components/snapshots/list';

import {
  fetchSnapshotsIfNeeded,
  loadNext,
  searchSnapshots,
  fetchSnapshot,
  deleteSnapshot,
} from '../../actions/snapshots'

export default connect(
  (state) => ({
    snapshots: state.snapshots
  }),
  dispatch => ({
    loadSnapshotsOnce: () => dispatch(fetchSnapshotsIfNeeded()),
    loadNext: () => dispatch(loadNext()),
    search: (term) => dispatch(searchSnapshots(term)),
    reloadSnapshot: (id) => dispatch(fetchSnapshot(id)),
    deleteSnapshot: (id) => dispatch(deleteSnapshot(id))
  })
)(SnapshotList);
