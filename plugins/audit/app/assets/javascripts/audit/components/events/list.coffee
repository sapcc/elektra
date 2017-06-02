#= require audit/components/events/item

# import
{ div, span, table, tbody, thead, tr, th, td, input } = React.DOM
{ connect } = ReactRedux
{ EventItem } = audit

Events = ({events, isFetching, loadEvents, filterEvents}) ->
  div null,
    div className: 'toolbar',
      input onChange: ((e) -> filterEvents('test','test'))

    table className: 'table events',
      thead null,
        tr null,
          th null, 'Time'
          th null, 'Source'
          th null, 'Event Type'
          th null, 'Resource'
          th null, 'User'
      tbody null,
        for event in events
          unless event.isVisible==false
            React.createElement EventItem, key: event.event_id, event: event

        if isFetching
          tr null,
            td colSpan: 2,
              span className: 'spinner'


# export
audit.EventList = Events
