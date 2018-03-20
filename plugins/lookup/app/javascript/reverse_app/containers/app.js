import { connect } from  'react-redux';
import App from '../components/app';
import { fetchProjectForm } from '../actions/project'

const mapStateToProps = state => {
  return {
    project: state.project,
    isFetching: state.project.isFetching
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
