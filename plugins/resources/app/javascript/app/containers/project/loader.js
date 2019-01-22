import { connect } from  'react-redux';
import ProjectLoader from '../../components/project/loader';
import { fetchProjectIfNeeded } from '../../actions/project';

export default connect(
  (state, props) => ({
    isFetching: state.project.isFetching || state.project.receivedAt == null,
    receivedAt: state.project.receivedAt,
  }),
  dispatch => ({
    loadProjectOnce: (args) => dispatch(fetchProjectIfNeeded(args)),
  }),
)(ProjectLoader);
