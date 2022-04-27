import { connect } from  'react-redux';
import { fetchData, simulateSetQuota, setQuota } from '../actions/limes';
import EditModal from '../components/edit';

export default connect(
  (state, props) => ({
    metadata: state.limes.metadata,
    category: state.limes.categories[props.match.params.categoryName],
    categoryName: props.match.params.categoryName,
  }),
  dispatch => ({
    fetchData:        (...args) => dispatch(fetchData(...args)),
    setQuota:         (...args) => dispatch(setQuota(...args)),
    simulateSetQuota: (...args) => dispatch(simulateSetQuota(...args)),
  }),
)(EditModal);
