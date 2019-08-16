import { connect } from  'react-redux';
import AutoscalingOpsReport from '../../components/autoscaling/ops_report';
import { fetchOperationsReportIfNeeded } from '../../actions/castellum';

const collectProjectNames = (autoscalableSubscopes) => {
  const result = {};
  for (const perService of Object.values(autoscalableSubscopes)) {
    for (const projects of Object.values(perService)) {
      for (const { id, name } of projects) {
        result[id] = name;
      }
    }
  }
  return result;
};

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
    report:       state.castellum.operationsReports[props.reportType],
    projectNames: collectProjectNames(state.limes.autoscalableSubscopes.bySrvAndRes || {}),
    units:        collectUnits(state.limes.categories || {}),
  }),
  dispatch => ({
    fetchOperationsReportIfNeeded: (...args) => dispatch(fetchOperationsReportIfNeeded(...args)),
  }),
)(AutoscalingOpsReport);
