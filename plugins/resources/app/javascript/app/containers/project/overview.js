import { connect } from  'react-redux';
import ProjectOverview from '../../components/project/overview';
import {
  fetchProjectIfNeeded,
} from '../../actions/project';

export default connect(
  (state, props) => ({
    isFetching: state.project.isFetching || state.project.receivedAt == null,
    metadata: state.project.metadata,
    overview: state.project.overview,
  }),
  dispatch => ({
    loadProjectOnce: (args) => dispatch(fetchProjectIfNeeded(args)),
  }),
)(ProjectOverview);
