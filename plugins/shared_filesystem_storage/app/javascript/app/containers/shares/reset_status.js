import { connect } from  'react-redux';
import ResetShareStatusModal from '../../components/shares/reset_status';
import {submitResetShareStatusForm,reloadShare} from '../../actions/shares';

export default connect(
  (state,ownProps ) => {
    let share;
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id

    if (id) {
      share = state.shares.items.find(item => item.id == id)
    }
    return { share, id }
  },
  (dispatch,ownProps) => {
    let id = ownProps.match && ownProps.match.params && ownProps.match.params.id
    return {
      handleSubmit: (values) => id ? dispatch(submitResetShareStatusForm(id,values)) : null,
      loadShare: () => id ? dispatch(reloadShare(id)) : null
    }
  }
)(ResetShareStatusModal);
