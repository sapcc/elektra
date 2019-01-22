import { connect } from  'react-redux';
import ProjectOverview from '../../components/project/overview';
import {
  fetchProjectIfNeeded,
  syncProject,
  pollRunningSyncProject,
} from '../../actions/project';

export default connect(
  (state, props) => ({
    isFetching: state.project.isFetching || state.project.receivedAt == null,
    metadata:   state.project.metadata,
    overview:   state.project.overview,
    syncStatus: state.project.syncStatus,
  }),
  dispatch => ({
    syncProject:            (args) => dispatch(syncProject(args)),
    pollRunningSyncProject: (args) => dispatch(pollRunningSyncProject(args)),
  }),
)(ProjectOverview);
