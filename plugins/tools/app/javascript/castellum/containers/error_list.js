import { connect } from  'react-redux';
import ErrorList from '../components/error_list';
import { fetchAllErrorsAsNeeded } from '../actions/castellum';

export default connect(
  (state, props) => {
    const { isFetching, requestedAt, data, errorMessage } = state.castellum[props.errorType];
    return {
      isFetching: isFetching || requestedAt === null,
      data,
      errorMessage,
    };
  },
  dispatch => ({
    fetchAllErrorsAsNeeded: (...args) => dispatch(fetchAllErrorsAsNeeded(...args)),
  }),
)(ErrorList);
