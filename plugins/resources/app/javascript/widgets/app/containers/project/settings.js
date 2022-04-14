import { connect } from  'react-redux';
import ProjectSettingsModal from '../../components/project/settings';
import { setProjectHasBursting } from '../../actions/limes';

export default connect(
  (state, props) => ({
    metadata: state.limes.metadata,
  }),
  dispatch => ({
    setProjectHasBursting: (args) => dispatch(setProjectHasBursting(args)),
  }),
)(ProjectSettingsModal);
