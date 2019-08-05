import { connect } from  'react-redux';
import AutoscalingConfig from '../../components/autoscaling/config';

export default connect(
  (state, props) => ({
    autoscalableSubscopes: state.limes.autoscalableSubscopes.bySrvAndRes,
    projectConfigs: state.castellum.projectConfigs,
  }),
  dispatch => ({
  }),
)(AutoscalingConfig);
