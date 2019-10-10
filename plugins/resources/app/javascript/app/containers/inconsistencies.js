import { connect } from  'react-redux';
import Inconsistencies from '../components/inconsistencies';
import { fetchInconsistenciesIfNeeded } from '../actions/limes';

export default connect(
  (state, props) => {
    const data = state.limes.inconsistencyData;
    return {
      isFetching:      data.isFetching || data.receivedAt == null,
      inconsistencies: data.data,
    };
  },
  dispatch => ({
    loadInconsistenciesOnce: (...args) => dispatch(fetchInconsistenciesIfNeeded(...args)),
  }),
)(Inconsistencies);
