#= require audit/components/events/list

{ div } = React.DOM
{ connect } = ReactRedux
{ EventList, loadNextEvents, filterEvents } = audit

App = React.createClass
  componentDidMount: ->
    @props.loadEvents()

  render: () ->
    React.createElement EventList, events: @props.events, isFetching: @props.isFetching, filter: @props.filter, loadNext: @props.loadNext

audit.App = connect(
  (state) ->
    events: state.events.items
    isFetching: state.events.isFetching
  (dispatch) ->
    loadEvents: () -> dispatch(loadNextEvents())
    loadNext: () -> dispatch(loadNextEvents())
    filter: (type,term) -> dispatch(filterEvents(type,term))
)(App)
