import { connect } from  'react-redux';
import ShowSnapshotModal from '../../components/snapshots/show';
import {fetchSnapshot} from '../../actions/snapshots';

export default connect(
  (state,ownProps ) => {
    let snapshot;
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id

    if (id) {
      snapshot = state.snapshots.items.find(item => item.id == id)
    }
    return { snapshot, id }
  },
  (dispatch,ownProps) => {
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id
    return {
      loadSnapshot: () => id ? dispatch(fetchSnapshot(id)) : null
    }
  }
)(ShowSnapshotModal);
