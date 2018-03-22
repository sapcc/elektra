import { connect } from  'react-redux';
import App from '../components/app';
import { fetchProjectForm } from '../actions/project'
import { fetchDomain } from '../actions/domain'

const mapStateToProps = state => {
  return {
    project: state.project,
    domain: state.domain,
    parents: state.parents
  }
}

const mapDispatchToProps = dispatch => {
  return {
    handleSubmit: (value) => dispatch(fetchProjectForm(value)),
    fetchDomain: (value) => dispatch(fetchDomain(value))
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(App);
