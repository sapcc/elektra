import { connect } from  'react-redux';
import ProjectOverview from '../../components/project/overview';
import {
  fetchProjectIfNeeded,
} from '../../actions/project';

export default connect(
  (state, props) => ({
    project: state.project,
  }),
  dispatch => ({
    loadProjectOnce: (args) => dispatch(fetchProjectIfNeeded(args)),
  }),
)(ProjectOverview);
