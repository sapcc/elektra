import { connect } from  'react-redux';
import App from '../components/app';
import { fetchObject } from '../actions/object'

const mapStateToProps = state => {
  return {
    object: state.object
  }
}

const mapDispatchToProps = dispatch => {
  return {
    handleSubmit: (value) => dispatch(fetchObject(value)),
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(App);
