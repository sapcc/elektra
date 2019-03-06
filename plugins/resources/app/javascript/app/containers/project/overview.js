import { connect } from  'react-redux';
import ProjectOverview from '../../components/project/overview';
import {
  syncProject,
  pollRunningSyncProject,
} from '../../actions/limes';

export default connect(
  (state, props) => ({
    isFetching: state.limes.isFetching || state.limes.receivedAt == null,
    metadata:   state.limes.metadata,
    overview:   state.limes.overview,
    syncStatus: state.limes.syncStatus,
  }),
  dispatch => ({
    syncProject:            (args) => dispatch(syncProject(args)),
    pollRunningSyncProject: (args) => dispatch(pollRunningSyncProject(args)),
  }),
)(ProjectOverview);
