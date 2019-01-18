import { connect } from  'react-redux';
import ProjectSettingsModal from '../../components/project/settings';
import { setProjectHasBursting } from '../../actions/project';

export default connect(
  (state, props) => ({
    metadata: state.project.metadata,
  }),
  dispatch => ({
    setProjectHasBursting: (args) => dispatch(setProjectHasBursting(args)),
  }),
)(ProjectSettingsModal);
