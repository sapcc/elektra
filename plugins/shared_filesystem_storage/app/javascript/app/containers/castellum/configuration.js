import { connect } from  'react-redux';
import CastellumConfiguration from '../../components/castellum/configuration';

export default connect(
  state => ({
    config: (state.castellum || {})['resources/nfs-shares'],
  }),
  dispatch => ({}),
)(CastellumConfiguration);
