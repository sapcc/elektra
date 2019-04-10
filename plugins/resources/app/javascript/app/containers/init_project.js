import { connect } from  'react-redux';
import { setQuota } from '../actions/limes';
import InitProjectModal from '../components/init_project';

export default connect(
  (state, props) => ({
    metadata:   state.limes.metadata,
    overview:   state.limes.overview,
    categories: state.limes.categories,
  }),
  dispatch => ({
    setQuota: (...args) => dispatch(setQuota(...args)),
  }),
)(InitProjectModal);
