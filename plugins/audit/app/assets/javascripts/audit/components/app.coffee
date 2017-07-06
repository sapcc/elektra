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
      filterEventsStartTime: @props.filterEventsStartTime,
      loadEvents: @props.loadEvents,
      filterStartTime: @props.filterStartTime

audit.App = connect(
  (state) ->
    events: state.events.items
    isFetching: state.events.isFetching
    filterStartTime: state.events.filterStartTime
  (dispatch) ->
    loadEvents: (offset) -> dispatch(fetchEvents(offset))
    # filterEventsStartTime: (filterStartTime) -> dispatch(filterEventsStartTime(filterStartTime))
)(App)
