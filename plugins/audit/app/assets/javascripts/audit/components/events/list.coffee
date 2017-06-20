#= require audit/components/events/item
#= require audit/components/events/item_details


# import
{ div, span, input, table, thead, tbody, tr, th, td } = React.DOM
{ connect } = ReactRedux
{ EventItem, EventItemDetails } = audit

Events = ({events, isFetching, loadEvents, filterEvents}) ->
  div null,
    div className: 'toolbar',
      input onChange: ((e) -> filterEvents('test','test'))

    table className: 'table',
      thead null,
        tr null,
          th className: 'icon-cell', ''
          th null, 'Time'
          th null, 'Source'
          th null, 'Event Type'
          th null, 'Resource'
          th className: 'user-cell', 'User'

      for event in events
        tbody null,
          React.createElement EventItem, key: event.event_id, event: event
          if event.detailsVisible
            React.createElement EventItemDetails, key: "#{event.event_id}_details", event: event

      if isFetching
        tbody null,
          tr null,
            td colSpan: '6',
              span className: 'spinner'

    # div className: 'events',
    #   div className: 'events-head',
    #     div className: 'event-cell', ''
    #     div className: 'event-cell', 'Time'
    #     div className: 'event-cell', 'Source'
    #     div className: 'event-cell', 'Event Type'
    #     div className: 'event-cell', 'Resource'
    #     div className: 'event-cell user-cell', 'User'
    #   # div className: 'events-list',
    #   for event in events
    #     div className: 'events-list',
    #       React.createElement EventItem, key: event.event_id, event: event
    #       if event.detailsVisible
    #         React.createElement EventItemDetails, key: "#{event.event_id}_details", event: event
    #
    #   if isFetching
    #     div className: 'event',
    #       div className: 'event-cell',
    #         span className: 'spinner'


# export
audit.EventList = Events
