#= require audit/components/events/list

{ div } = React.DOM
{ connect } = ReactRedux
{ EventList, fetchEvents } = audit

App = React.createClass
  componentDidMount: ->
    @props.loadEvents(0)

  render: () ->
    React.createElement EventList,
      events: @props.events,
      isFetching: @props.isFetching,
      loadEvents: @props.loadEvents



audit.App = connect(
  (state) ->
    events: state.events.items
    isFetching: state.isFetching



  (dispatch) ->
    loadEvents: (offset) -> dispatch(fetchEvents(offset))
)(App)
