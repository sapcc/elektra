import { connect } from  'react-redux';
import EditShareModal from '../../components/shares/edit';
import { submitEditShareForm } from '../../actions/shares'

export default connect(
  (state,ownProps ) => {
    let share;
    if (ownProps.match && ownProps.match.params && ownProps.match.params.id) {
      let shares = state.shared_filesystem_storage.shares.items
      if (shares) share = shares.find(item => item.id==ownProps.match.params.id)
    }
    return { share }
  },
  dispatch => ({
    handleSubmit: (values,{handleSuccess,handleErrors}) => (
      dispatch(submitEditShareForm(values,{handleSuccess,handleErrors}))
    )
  })
)(EditShareModal);
