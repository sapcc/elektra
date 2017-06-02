#= require audit/components/events/list

{ div } = React.DOM
{ connect } = ReactRedux
{ EventList, fetchEvents, filterEvents } = audit

App = React.createClass
  componentDidMount: ->
    @props.loadEvents(0)

  render: () ->
    React.createElement EventList,
      events: @props.events,
      isFetching: @props.isFetching,
      filterEvents: @props.filterEvents,
      loadEvents: @props.loadEvents

audit.App = connect(
  (state) ->
    events: state.events.items
    isFetching: state.events.isFetching
  (dispatch) ->
    loadEvents: (offset) -> dispatch(fetchEvents(offset))
    filterEvents: (type, term) -> dispatch(filterEvents(type, term))
)(App)
