import { connect } from  'react-redux';
import App from '../components/app';
import { fetchCostReport } from '../actions/cost'

const mapStateToProps = state => {
  return {
    report: state.report
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
