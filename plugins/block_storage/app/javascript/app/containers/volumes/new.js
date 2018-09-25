import { connect } from  'react-redux';
import NewVolumeModal from '../../components/volumes/new';
import {fetchAvailabilityZonesIfNeeded, submitNewVolumeForm} from '../../actions/volumes';

export default connect(
  (state ) => (
    {
      availabilityZones: state.availabilityZones
    }
  ),
  (dispatch) => (
    {
      loadAvailabilityZonesOnce: () => dispatch(fetchAvailabilityZonesIfNeeded()),
      handleSubmit: (values) => dispatch(submitNewVolumeForm(values))
    }
  )
)(NewVolumeModal);
