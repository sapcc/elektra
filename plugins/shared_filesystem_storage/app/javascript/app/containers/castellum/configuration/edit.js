import { connect } from  'react-redux';
import { configureAutoscaling } from '../../../actions/castellum';
import CastellumConfigurationEditModal from '../../../components/castellum/configuration/edit';

export default connect(
  state => ({
    config: (state.castellum || {})['resources/nfs-shares'],
  }),
  dispatch => ({
    configureAutoscaling: (projectID, cfg) => dispatch(configureAutoscaling(projectID, cfg)),
  }),
)(CastellumConfigurationEditModal);

