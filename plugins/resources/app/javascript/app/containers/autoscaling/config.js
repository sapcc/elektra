import { connect } from  'react-redux';
import AutoscalingConfig from '../../components/autoscaling/config';
import {
  deleteCastellumProjectResource,
  updateCastellumProjectResource,
} from '../../actions/castellum';

export default connect(
  (state, props) => ({
    autoscalableSubscopes: state.limes.autoscalableSubscopes.bySrvAndRes,
    projectConfigs: state.castellum.projectConfigs,
  }),
  dispatch => ({
    deleteCastellumProjectResource: (...args) => dispatch(deleteCastellumProjectResource(...args)),
    updateCastellumProjectResource: (...args) => dispatch(updateCastellumProjectResource(...args)),
  }),
)(AutoscalingConfig);
