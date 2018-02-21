import { connect } from  'react-redux'
import EventList from '../../components/events/list'
import {
  filterEventsStartTime,
  filterEventsEndTime,
  filterEventsFilterType,
  filterEventsFilterTerm,
  clearFilters } from '../../actions/events'

export default connect(
  (state) => (
    {
      filterStartTime:            state.events.filterStartTime,
      filterEndTime:              state.events.filterEndTime,
      filterType:                 state.events.filterType,
      filterTerm:                 state.events.filterTerm,
      attributeValues:            state.events.attributeValues,
      isFetchingAttributeValues:  state.events.isFetchingAttributeValues,
      offset:                     state.events.offset,
      limit:                      state.events.limit,
      total:                      state.events.total,
      error:                      state.events.error
    }
  ),
  (dispatch) =>(
    {
      handleStartTimeChange:  (filterStartTime)     => dispatch(filterEventsStartTime(filterStartTime)),
      handleEndTimeChange:    (filterEndTime)       => dispatch(filterEventsEndTime(filterEndTime)),
      handleFilterTypeChange: (filterType)          => dispatch(filterEventsFilterType(filterType)),
      handleFilterTermChange: (filterTerm, timeout) => dispatch(filterEventsFilterTerm(filterTerm, timeout)),
      handleClearFilters:     ()                    => dispatch(clearFilters())
    }
  )
)(EventList)
