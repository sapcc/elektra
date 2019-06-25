import { connect } from  'react-redux';
import CastellumTabs from '../../components/castellum/tabs';
import {
  fetchCastellumResourceConfigIfNeeded,
} from '../../actions/castellum';

export default connect(
  state => {
    const castellumState = state.castellum || {};
    return {
      resourceConfig: castellumState.resourceConfig,
    };
  },
  dispatch => ({
    loadResourceConfigOnce: (projectID) => dispatch(fetchCastellumResourceConfigIfNeeded(projectID)),
  }),
)(CastellumTabs);
