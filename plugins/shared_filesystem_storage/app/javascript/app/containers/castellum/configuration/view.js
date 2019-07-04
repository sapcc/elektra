import { connect } from  'react-redux';
import CastellumConfigurationView from '../../../components/castellum/configuration/view';
import { disableAutoscaling } from '../../../actions/castellum';

export default connect(
  state => ({
    config: (state.castellum || {})['resources/nfs-shares'],
  }),
  dispatch => ({
    disableAutoscaling: (projectID) => dispatch(disableAutoscaling(projectID)),
  }),
)(CastellumConfigurationView);
