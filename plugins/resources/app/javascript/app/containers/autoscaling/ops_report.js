import { connect } from  'react-redux';
import AutoscalingOpsReport from '../../components/autoscaling/ops_report';
import { fetchOperationsReportIfNeeded } from '../../actions/castellum';

export default connect(
  (state, props) => ({
    report: state.castellum.operationsReports[props.reportType],
  }),
  dispatch => ({
    fetchOperationsReportIfNeeded: (...args) => dispatch(fetchOperationsReportIfNeeded(...args)),
  }),
)(AutoscalingOpsReport);
