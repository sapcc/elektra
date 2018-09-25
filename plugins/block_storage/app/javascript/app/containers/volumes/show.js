import { connect } from  'react-redux';
import ShowVolumeModal from '../../components/volumes/show';
import {fetchVolume} from '../../actions/volumes';

export default connect(
  (state,ownProps ) => {
    let volume;
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id

    if (id) {
      volume = state.volumes.items.find(item => item.id == id)
    }
    return { volume, id }
  },
  (dispatch,ownProps) => {
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id
    return {
      loadVolume: () => id ? dispatch(fetchVolume(id)) : null
    }
  }
)(ShowVolumeModal);
