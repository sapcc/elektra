import { connect } from  'react-redux';
import ShowEntryModal from '../../components/entries/show';
import { fetchEntryExportLocationsIfNeeded } from '../../actions/entries'

export default connect(
  (state,ownProps ) => {
    let entry;
    let match = ownProps.match
    if (match && match.params && match.params.id) {
      let entries = state.entries.items
      if (entries) entry = entries.find(item => item.id==match.params.id)
    }

    return { entry }
  },
  dispatch => ({})
)(ShowEntryModal);
