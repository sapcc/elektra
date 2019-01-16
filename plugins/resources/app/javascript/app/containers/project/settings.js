import { connect } from  'react-redux';
import ProjectSettingsModal from '../../components/project/settings';

export default connect(
  (state, props) => ({
    metadata: state.project.metadata,
  }),
  dispatch => ({
  }),
)(ProjectSettingsModal);
