import { connect } from  'react-redux';
import CastellumTabs from '../../components/castellum/tabs';
import {
  fetchCastellumDataIfNeeded,
} from '../../actions/castellum';

export default connect(
  state => ({
    config: (state.castellum || {})['resources/nfs-shares'],
  }),
  dispatch => ({
    loadResourceConfigOnce: (projectID) =>
      dispatch(fetchCastellumDataIfNeeded(projectID, 'resources/nfs-shares')),
  }),
)(CastellumTabs);
