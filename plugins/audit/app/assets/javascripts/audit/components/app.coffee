#= require audit/components/events/list

{ div } = React.DOM
{ connect } = ReactRedux
{ EventList, fetchEvents, filterEventsStartTime } = audit

App = React.createClass
  componentDidMount: ->
    @props.loadEvents(0)

  render: () ->
    React.createElement EventList,
      events: @props.events,
      isFetching: @props.isFetching,
      loadEvents: @props.loadEvents,
      filterEventsStartTime: @props.filterEventsStartTime,
      filterEventsEndTime: @props.filterEventsEndTime,
      filterStartTime: @props.filterStartTime,
      filterEndTime: @props.filterEndTime,
      filterType: @props.filterType,
      filterTerm: @props.filterTerm



audit.App = connect(
  (state) ->
    events: state.events.items
    isFetching: state.events.isFetching
    filterStartTime: state.events.filterStartTime
    filterEndTime: state.events.filterEndTime
    filterType: state.events.filterType
    filterTerm: state.events.filterTerm


  (dispatch) ->
    loadEvents: (offset) -> dispatch(fetchEvents(offset))
    # filterEventsStartTime: (filterStartTime) -> dispatch(filterEventsStartTime(filterStartTime))
)(App)
