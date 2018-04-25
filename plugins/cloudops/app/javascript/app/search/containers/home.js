import { connect } from  'react-redux';
import Home from '../components/home';

import { searchObjects, loadNextObjects } from '../actions/objects'

import { fetchTypesIfNeeded } from '../actions/types'

export default connect(
  (state) => ({
    objects: state.search.objects,
    types: state.search.types
  }),
  dispatch => ({
    search: (searchOptions) => dispatch(searchObjects(searchOptions)),
    loadTypesOnce: () => dispatch(fetchTypesIfNeeded()),
    loadNext:(searchOptions) => dispatch(loadNextObjects(searchOptions))
  })
)(Home);
