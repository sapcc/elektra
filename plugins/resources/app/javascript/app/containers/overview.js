import { connect } from  'react-redux';
import Overview from '../components/overview';
import {
  syncProject,
  pollRunningSyncProject,
} from '../actions/limes';

export default connect(
  (state, props) => ({
    isFetching: state.limes.isFetching || state.limes.receivedAt == null,
    metadata:   state.limes.metadata,
    overview:   state.limes.overview,
    syncStatus: state.limes.syncStatus,
    canAutoscale: !state.limes.autoscalableSubscopes.isEmpty,
  }),
  dispatch => ({
    syncProject:            (args) => dispatch(syncProject(args)),
    pollRunningSyncProject: (args) => dispatch(pollRunningSyncProject(args)),
  }),
)(Overview);
