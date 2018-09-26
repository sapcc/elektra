import { connect } from  'react-redux';
import CloneVolumeModal from '../../components/volumes/clone_volume';
import {
  fetchAvailabilityZonesIfNeeded,
  submitCloneVolumeForm,
  fetchVolume
} from '../../actions/volumes';

export default connect(
  (state,ownProps ) => {
    let volume;
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id

    if (id) {
      volume = state.volumes.items.find(item => item.id == id)
    }
    return { volume, id, availabilityZones: state.availabilityZones }
  },
  (dispatch,ownProps) => {
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id
    return {
      loadAvailabilityZonesOnce: () => dispatch(fetchAvailabilityZonesIfNeeded()),
      handleSubmit: (values) => dispatch(submitCloneVolumeForm(values)),
      loadVolume: () => id ? dispatch(fetchVolume(id)) : null
    }
  }
)(CloneVolumeModal);
