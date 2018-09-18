import { connect } from  'react-redux';
import SnapshotList from '../../components/snapshots/list';

import {fetchSnapshotsIfNeeded} from '../../actions/snapshots'

export default connect(
  (state) => ({
    snapshots: state.snapshots
  }),
  dispatch => ({
    loadSnapshotsOnce: () => dispatch(fetchSnapshotsIfNeeded())
  })
)(SnapshotList);
