import { connect } from  'react-redux';
import CastellumConfigurationView from '../../../components/castellum/configuration/view';

export default connect(
  state => ({
    config: (state.castellum || {})['resources/nfs-shares'],
  }),
  dispatch => ({}),
)(CastellumConfigurationView);
