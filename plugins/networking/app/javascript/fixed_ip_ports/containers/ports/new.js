import { connect } from  'react-redux';
import NewShareModal from '../../components/ports/new';
import { submitNewPortForm } from '../../actions/ports';
import { fetchNetworksIfNeeded } from '../../actions/networks';
import { fetchSubnetsIfNeeded } from '../../actions/subnets';

export default connect(
  (state,ownProps ) => ({
    networks: state.networks,
    subnets: state.subnets
  }),
  dispatch => ({
    handleSubmit: (values) => dispatch(submitNewPortForm(values)),
    loadNetworksOnce: () => dispatch(fetchNetworksIfNeeded()),
    loadSubnetsOnce: () => dispatch(fetchSubnetsIfNeeded())
  })
)(NewShareModal);
