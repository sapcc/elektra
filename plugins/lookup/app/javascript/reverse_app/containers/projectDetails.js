import { connect } from  'react-redux';
import ProjectDetails from '../components/projectDetails';

const mapStateToProps = state => {
  return {
    domain: state.domain,
    parents: state.parents,
    users: state.users,
    groups: state.groups
  }
}

const mapDispatchToProps = dispatch => {
  return {
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(ProjectDetails);
