import { connect } from  'react-redux';
import EditEntryModal from '../../components/entries/edit';
import { submitEditEntryForm } from '../../actions/entries'

export default connect(
  (state, ownProps ) => {
    let entry;
    if (ownProps.match && ownProps.match.params && ownProps.match.params.id &&
        state.entries.items) {
      entry = state.entries.items.find(i => i.id==ownProps.match.params.id)
    }
    return { entry }
  },
  dispatch => ({
    handleSubmit: (values) => dispatch(submitEditEntryForm(values))
  })
)(EditEntryModal);
