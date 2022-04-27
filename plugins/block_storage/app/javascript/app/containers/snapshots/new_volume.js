import { connect } from  'react-redux';
import NewSnapshotVolumeModal from '../../components/snapshots/new_volume';
import {submitNewVolumeForm, fetchVolume} from '../../actions/volumes';

export default connect(
  (state,ownProps ) => {
    let snapshot;
    let volume;
    let snapshot_id = ownProps.match && ownProps.match.params && ownProps.match.params.snapshot_id

    if (snapshot_id) {
      snapshot = state.snapshots.items.find(item => item.id == snapshot_id)
      if (snapshot) {
        volume = state.volumes.items.find(item => item.id == snapshot.volume_id)
      }
    }
    return { snapshot, snapshot_id, volume }
  },
  (dispatch) => (
    {
      handleSubmit: (values) => dispatch(submitNewVolumeForm(values)),
      loadVolume: (id) => dispatch(fetchVolume(id))
    }
  )
)(NewSnapshotVolumeModal);
