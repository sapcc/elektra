import { connect } from  'react-redux';
import EditSnapshotModal from '../../components/snapshots/edit';
import { submitEditSnapshotForm } from '../../actions/snapshots';

export default connect(
  (state,ownProps) => {
    let snapshot;
    if (ownProps.match && ownProps.match.params &&
        ownProps.match.params.id && state.snapshots.items ) {
      snapshot = state.snapshots.items.find(i => i.id==ownProps.match.params.id)
    }
    return {snapshot}
  },
  (dispatch,ownProps) => ({
    handleSubmit: (values) => dispatch(submitEditSnapshotForm(
      Object.assign(values,{id:ownProps.match.params.id})
    ))
  })
)(EditSnapshotModal)
