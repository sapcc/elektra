import { connect } from "react-redux"
import Home from "../components/home"

import {
  searchObjects,
  loadNextObjects,
  loadObjectsPage,
} from "../actions/objects"

import { fetchTypesIfNeeded } from "../actions/types"
import { fetchAggregatesIfNeeded } from "../actions/aggregates"

export default connect(
  (state) => ({
    objects: state.search.objects,
    types: state.search.types,
    aggregates: state.search.aggregates,
    searchTerm: (state.search.objects || {}).searchTerm,
    searchType: (state.search.objects || {}).searchType,
  }),
  (dispatch) => ({
    search: (searchOptions) => dispatch(searchObjects(searchOptions)),
    loadTypesOnce: () => dispatch(fetchTypesIfNeeded()),
    loadNext: () => dispatch(loadNextObjects()),
    loadPage: (page) => dispatch(loadObjectsPage(page)),
    loadAggregatesOnce: () => dispatch(fetchAggregatesIfNeeded()),
  })
)(Home)
