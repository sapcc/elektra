import { connect } from  'react-redux';
import AutoscalingConfig from '../../components/autoscaling/config';
import {
  deleteCastellumProjectResource,
  updateCastellumProjectResource,
} from '../../actions/castellum';

//TODO code duplication with ./ops_report.js
const collectUnits = (categories) => {
  const result = {};
  for (const category of Object.values(categories)) {
    for (const resource of category.resources) {
      const assetType = `project-quota:${category.serviceType}:${resource.name}`;
      result[assetType] = resource.unit;
    }
  }
  return result;
};

export default connect(
  (state, props) => ({
    autoscalableSubscopes: state.limes.autoscalableSubscopes.bySrvAndRes,
    projectConfigs: state.castellum.projectConfigs,
    units:          collectUnits(state.limes.categories || {}),
  }),
  dispatch => ({
    deleteCastellumProjectResource: (...args) => dispatch(deleteCastellumProjectResource(...args)),
    updateCastellumProjectResource: (...args) => dispatch(updateCastellumProjectResource(...args)),
  }),
)(AutoscalingConfig);
