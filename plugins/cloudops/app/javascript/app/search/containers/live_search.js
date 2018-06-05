import { connect } from  'react-redux';
import LiveSearchModal from '../components/live_search';
import { liveSearch } from '../actions/objects'

export default connect(
  state => (
    {
      types: state.search.types,
      term: state.search.objects.searchTerm,
      objectType: state.search.objects.searchType
    }
  ),
  dispatch => ({
    search: (type,term) => dispatch(liveSearch(type, term))
  })
)(LiveSearchModal);
