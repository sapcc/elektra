import { connect } from  'react-redux';
import ErrorMessageList from '../../components/error_messages/list';

import {
  fetchErrorMessagesIfNeeded,
  searchErrorMessages,
  loadNext
} from '../../actions/error_messages'

export default connect(
  (state,ownProps) => {
    let errorMessages;

    let match = ownProps.match
    if (match && match.params && match.params.id) {

      errorMessages = state.errorMessages[match.params.id]
    }

    return {errorMessages}
  },

  (dispatch,ownProps) => {
    let resourceId;
    let match = ownProps.match
    if (match && match.params && match.params.id) {
      resourceId = match.params.id
    }

    return {
      loadErrorMessagesOnce: () => dispatch(fetchErrorMessagesIfNeeded(resourceId)),
      loadNext: () => dispatch(loadNext(resourceId)),
      searchErrorMessages: (term) => dispatch(searchErrorMessages(resourceId,term))
    }
  }
)(ErrorMessageList);
