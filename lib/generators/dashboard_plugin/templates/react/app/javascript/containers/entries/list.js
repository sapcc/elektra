import { connect } from  'react-redux';
import EntryList from '../../components/entries/list';
import {
  fetchEntriesIfNeeded,
  deleteEntry,
  editEntry,
  filterEntries
} from '../../actions/entries'

export default connect(
  (state) => ({
    items: state.entries.items,
    isFetching: state.entries.isFetching
  }),
  dispatch => ({
    loadEntriesOnce: () => dispatch(fetchEntriesIfNeeded()),
    filterEntries: (term) => dispatch(filterEntries(term)),
    handleDelete: (entryId) => dispatch(deleteEntry(entryId))
  })
)(EntryList);
