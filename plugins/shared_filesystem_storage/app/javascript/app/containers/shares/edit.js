import { connect } from  'react-redux';
import EditShareModal from '../../components/shares/edit';
import { submitEditShareForm } from '../../actions/shares';
import { fetchShareTypesIfNeeded } from '../../actions/share_types';

export default connect(
  (state,ownProps ) => {
    let share;
    if (ownProps.match && ownProps.match.params && ownProps.match.params.id) {
      let shares = state.shares.items
      if (shares) share = shares.find(item => item.id==ownProps.match.params.id)
    }
    return { share, shareTypes: state.shareTypes }
  },
  dispatch => ({
    handleSubmit: (values) => dispatch(submitEditShareForm(values)),
    loadShareTypesOnce: () => dispatch(fetchShareTypesIfNeeded())
  })
)(EditShareModal);
