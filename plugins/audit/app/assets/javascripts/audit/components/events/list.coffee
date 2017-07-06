#= require audit/components/events/item
#= require audit/components/events/item_details


# import
{ div, span, i, input, table, thead, tbody, tr, th, td } = React.DOM
{ connect } = ReactRedux
{ EventItem, EventItemDetails, filterEventsStartTime } = audit

Events = ({events, isFetching, loadEvents, filterEventsStartTime, filterStartTime}) ->
  div null,
    div className: 'toolbar',
      React.createElement Datetime, value: filterStartTime, onChange: ((e) -> filterEventsStartTime(e))


      # input onChange: ((e) -> filterEvents('test','test'))
      # div className: 'input-append date', id: 'datetimepicker-start',
      #   input className: 'span2', size: '16', type: 'text', value: ''
      #   span className: 'add-on',
      #     i className: 'fa fa-th'

    table className: 'table',
      thead null,
        tr null,
          th className: 'icon-cell', ''
          th null, 'Time'
          th null, 'Source'
          th null, 'Event Type'
          th null, 'Resource'
          th className: 'user-cell', 'User'

      if events
        for event in events
          tbody null,
            React.createElement EventItem, key: event.event_id, event: event
            if event.detailsVisible
              React.createElement EventItemDetails, key: "#{event.event_id}_details", event: event
      else
        tbody null,
          tr null,
            td colSpan: '6',
              'No events found'

      if isFetching
        tbody null,
          tr null,
            td colSpan: '6',
              span className: 'spinner'

Events = connect(
  (state) ->
    filterStartTime: state.filterStartTime
  (dispatch) ->
    filterEventsStartTime: (filterStartTime) -> dispatch(filterEventsStartTime(filterStartTime))

)(Events)


# export
audit.EventList = Events
