import { connect } from  'react-redux';
import NewSnapshotModal from '../../components/snapshots/new';
import {submitNewSnapshotForm} from '../../actions/snapshots';

export default connect(
  (state,ownProps ) => {
    let volume;
    let volume_id = ownProps.match && ownProps.match.params && ownProps.match.params.volume_id

    if (volume_id) {
      volume = state.volumes.items.find(item => item.id == volume_id)
    }
    return { volume, volume_id }
  },
  (dispatch) => (
    {
      handleSubmit: (values) => dispatch(submitNewSnapshotForm(values))
    }
  )
)(NewSnapshotModal);
