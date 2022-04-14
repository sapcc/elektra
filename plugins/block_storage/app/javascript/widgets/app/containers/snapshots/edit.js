import { connect } from  'react-redux';
import EditSnapshotModal from '../../components/snapshots/edit';
import {submitEditSnapshotForm,fetchSnapshot} from '../../actions/snapshots';

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
      handleSubmit: (values) => dispatch(submitEditSnapshotForm(id,values)),
      loadSnapshot: () => id ? dispatch(fetchSnapshot(id)) : null
    }
  }
)(EditSnapshotModal);
