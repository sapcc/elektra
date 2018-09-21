import { connect } from  'react-redux';
import SnapshotList from '../../components/snapshots/list';

import {fetchSnapshotsIfNeeded, loadNext, searchSnapshots} from '../../actions/snapshots'

export default connect(
  (state) => ({
    snapshots: state.snapshots
  }),
  dispatch => ({
    loadSnapshotsOnce: () => dispatch(fetchSnapshotsIfNeeded()),
    loadNext: () => dispatch(loadNext()),
    search: (term) => dispatch(searchSnapshots(term)),
  })
)(SnapshotList);
