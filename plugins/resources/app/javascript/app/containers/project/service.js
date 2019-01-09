import { connect } from  'react-redux';
import ProjectService from '../../components/project/service';

export default connect(
  (state, props) => ({
    metadata: state.project.metadata,
    service:  state.project.services[props.serviceType],
  }),
  dispatch => ({}),
)(ProjectService);
