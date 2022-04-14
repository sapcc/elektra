import { connect } from  'react-redux';
import RestSnapshotStatusModal from '../../components/snapshots/reset_status';
import {submitResetSnapshotStatusForm,fetchSnapshot} from '../../actions/snapshots';

export default connect(
  (state,ownProps ) => {
    let snapshot;
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id

    if (id) {
      snapshot = state.snapshots.items.find(item => item.id == id)
    }
    return { snapshot, id }
  },
  (dispatch,ownProps) => {
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id
    return {
      handleSubmit: (values) => id ? dispatch(submitResetSnapshotStatusForm(id,values)) : null,
      loadSnapshot: () => id ? dispatch(fetchSnapshot(id)) : null
    }
  }
)(RestSnapshotStatusModal);
