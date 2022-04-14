import { connect } from  'react-redux';
import NewVolumeModal from '../../components/volumes/new';
import {
  fetchAvailabilityZonesIfNeeded,
  submitNewVolumeForm,
  fetchImagesIfNeeded,
  fetchVolumeTypesIfNeeded,
} from '../../actions/volumes';

export default connect(
  (state ) => (
    {
      availabilityZones: state.availabilityZones,
      images: state.images,
      volumes: state.volumes
    }
  ),
  (dispatch) => (
    {
      loadImagesOnce: () => dispatch(fetchImagesIfNeeded()),
      loadVolumeTypesOnce: () => dispatch(fetchVolumeTypesIfNeeded()),
      loadAvailabilityZonesOnce: () => dispatch(fetchAvailabilityZonesIfNeeded()),
      handleSubmit: (values) => dispatch(submitNewVolumeForm(values))
    }
  )
)(NewVolumeModal);
