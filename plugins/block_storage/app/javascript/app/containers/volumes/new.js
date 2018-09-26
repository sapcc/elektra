import { connect } from  'react-redux';
import NewVolumeModal from '../../components/volumes/new';
import {
  fetchAvailabilityZonesIfNeeded,
  submitNewVolumeForm,
  fetchImagesIfNeeded
} from '../../actions/volumes';

export default connect(
  (state ) => (
    {
      availabilityZones: state.availabilityZones,
      images: state.images
    }
  ),
  (dispatch) => (
    {
      loadImagesOnce: () => dispatch(fetchImagesIfNeeded()),
      loadAvailabilityZonesOnce: () => dispatch(fetchAvailabilityZonesIfNeeded()),
      handleSubmit: (values) => dispatch(submitNewVolumeForm(values))
    }
  )
)(NewVolumeModal);
