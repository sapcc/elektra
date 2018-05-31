import { connect } from  'react-redux';
import App from '../components/app';
import { fetchCostReport } from '../actions/cost'

const mapStateToProps = state => {
  return {
    cost: state.cost
  }
}

const mapDispatchToProps = dispatch => {
  return {
    fetchCostReport: (value) => dispatch(fetchCostReport(value)),
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(App);
