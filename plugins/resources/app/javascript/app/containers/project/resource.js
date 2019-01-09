import { connect } from  'react-redux';
import ProjectResource from '../../components/project/resource';

export default connect(
  (state, props) => ({
    metadata: state.project.metadata,
    resource: state.project.resources[props.fullResourceName],
  }),
  dispatch => ({}),
)(ProjectResource);
