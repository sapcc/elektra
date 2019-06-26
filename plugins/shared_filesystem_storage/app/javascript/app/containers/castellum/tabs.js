import { connect } from  'react-redux';
import CastellumTabs from '../../components/castellum/tabs';
import {
  fetchCastellumResourceConfigIfNeeded,
} from '../../actions/castellum';

export default connect(
  state => ({
    resourceConfig: (state.castellum || {}).resourceConfig,
  }),
  dispatch => ({
    loadResourceConfigOnce: (projectID) => dispatch(fetchCastellumResourceConfigIfNeeded(projectID)),
  }),
)(CastellumTabs);
