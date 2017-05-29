#= require audit/components/events/item

# import
{ div, span, table, tbody, thead, tr, th, td } = React.DOM
{ connect } = ReactRedux
{ EventItem } = audit

Events = ({events, isFetching}) ->
  div null,
    div className: 'toolbar'

    if isFetching
      span className: 'spinner'
    else
      table className: 'table events',
        thead null,
          tr null,
            th null, 'Event Type'
            th null, 'Resource Name'
        tbody null,
          for event in events
            unless event.isVisible==false
              React.createElement EventItem, key: event.event_id, event: event

# export
audit.EventList = Events
