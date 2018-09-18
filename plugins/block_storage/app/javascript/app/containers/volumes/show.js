import { connect } from  'react-redux';
import ShowVolumeModal from '../../components/volumes/show';

export default connect(
  (state,ownProps ) => {
    let volume;
    let match = ownProps.match

    if (match && match.params && match.params.id) {
      volume = state.volumes.items.find(item => item.id == match.params.id)
    }
    return { volume }
  }
)(ShowVolumeModal);
