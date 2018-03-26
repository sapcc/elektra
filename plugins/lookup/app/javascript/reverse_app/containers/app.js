import { connect } from  'react-redux';
import App from '../components/app';
import { fetchProjectForm } from '../actions/project'
import { fetchDomain } from '../actions/domain'

const mapStateToProps = state => {
  return {
    project: state.project,
    domain: state.domain,
    parents: state.parents,
    users: state.users
  }
}

const mapDispatchToProps = dispatch => {
  return {
    handleSubmit: (value) => dispatch(fetchProjectForm(value))
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(App);
