import { connect } from  'react-redux';
import Loader from '../components/loader';
import {
  discoverAutoscalableSubscopesIfNeeded,
  fetchDataIfNeeded,
} from '../actions/limes';

export default connect(
  (state, props) => ({
    isFetching:   state.limes.isFetching || state.limes.receivedAt == null,
    receivedAt:   state.limes.receivedAt,
    isIncomplete: state.limes.isIncomplete,
  }),
  dispatch => ({
    loadDataOnce: (args) => dispatch(fetchDataIfNeeded(args)),
    discoverAutoscalableSubscopesOnce: (args) => dispatch(discoverAutoscalableSubscopesIfNeeded(args)),
  }),
)(Loader);
