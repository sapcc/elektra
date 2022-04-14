import { connect } from  'react-redux';
import NewSnapshotModal from '../../components/snapshots/new';
import { submitNewSnapshotForm } from '../../actions/snapshots';

export default connect(
  (state,ownProps) => {
    let share;
    if (ownProps.match && ownProps.match.params && ownProps.match.params.id) {
      let shares = state.shares.items
      if (shares) share = shares.find(item => item.id==ownProps.match.params.id)
    }
    return {share}
  },
  (dispatch,ownProps) => ({
    handleSubmit: (values) => dispatch(submitNewSnapshotForm(
      Object.assign(values,{share_id:ownProps.match.params.id})
    ))
  })
)(NewSnapshotModal);
