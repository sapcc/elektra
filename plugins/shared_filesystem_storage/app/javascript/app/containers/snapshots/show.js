import { connect } from  'react-redux';
import ShowShareModal from '../../components/snapshots/show';

export default connect(
  (state,ownProps ) => {
    let snapshot;
    if (ownProps.match &&
        ownProps.match.params &&
        ownProps.match.params.id &&
        state.snapshots.items) {
      snapshot = state.snapshots.items.find(i =>
        i.id==ownProps.match.params.id
      )
    }

    return { snapshot }
  },
  dispatch => ({})
)(ShowShareModal);
