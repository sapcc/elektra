import { connect } from  'react-redux';
import CastellumConfiguration from '../../components/castellum/configuration';

export default connect(
  state => ({
    resourceConfig: (state.castellum || {}).resourceConfig,
  }),
  dispatch => ({}),
)(CastellumConfiguration);
