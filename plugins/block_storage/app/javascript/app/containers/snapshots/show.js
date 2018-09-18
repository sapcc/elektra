import { connect } from  'react-redux';
import ShowSnapshotModal from '../../components/snapshots/show';

export default connect(
  (state,ownProps ) => {
    let snapshot;
    let match = ownProps.match

    if (match && match.params && match.params.id) {
      snapshot = state.snapshots.items.find(item => item.id == match.params.id)
    }
    return { snapshot }
  }
)(ShowSnapshotModal);
