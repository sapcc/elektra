#= require audit/components/events/item

# import
{ div, span, input } = React.DOM
{ connect } = ReactRedux
{ EventItem } = audit

Events = ({events, isFetching, loadEvents, filterEvents}) ->
  div null,
    div className: 'toolbar',
      input onChange: ((e) -> filterEvents('test','test'))

    div className: 'events',
      div className: 'events-head',
        div className: 'event-cell', 'Time'
        div className: 'event-cell', 'Source'
        div className: 'event-cell', 'Event Type'
        div className: 'event-cell', 'Resource'
        div className: 'event-cell', 'User'
      div className: 'events-list',
        for event in events
          unless event.isVisible==false
            React.createElement EventItem, key: event.event_id, event: event

        if isFetching
          span className: 'spinner'


# export
audit.EventList = Events
