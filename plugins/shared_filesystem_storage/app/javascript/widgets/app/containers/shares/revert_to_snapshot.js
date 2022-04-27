import { connect } from  'react-redux';
import ResetShareStatusModal from '../../components/shares/revert_to_snapshot';
import {submitRevertToSnapshotForm,reloadShare} from '../../actions/shares';
import { fetchSnapshotsIfNeeded } from '../../actions/snapshots';

export default connect(
  (state,ownProps ) => {
    let share;
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id

    if (id) {
      share = state.shares.items.find(item => item.id == id)
    }

    return {
      share,
      id,
      isFetchingSnapshots: state.snapshots.isFetching,
      snapshots: state.snapshots.items.filter(s => s.share_id==id)
    }
  },
  (dispatch,ownProps) => {
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id
    return {
      handleSubmit: (values) => id ? dispatch(submitRevertToSnapshotForm(id,values)) : null,
      loadShare: () => id ? dispatch(reloadShare(id)) : null,
      loadSnapshotsOnce: () => dispatch(fetchSnapshotsIfNeeded())
    }
  }
)(ResetShareStatusModal);
