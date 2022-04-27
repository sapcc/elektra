import { connect } from  'react-redux';
import EditShareSizeModal from '../../components/shares/edit_size';
import { submitEditShareSizeForm } from '../../actions/shares';

export default connect(
  (state,ownProps ) => {
    let share;
    if (ownProps.match && ownProps.match.params && ownProps.match.params.id) {
      let shares = state.shares.items
      if (shares) share = shares.find(item => item.id==ownProps.match.params.id)
    }
    return { share }
  },
  dispatch => ({
    handleSubmit: (values) => dispatch(submitEditShareSizeForm(values))
  })
)(EditShareSizeModal);
