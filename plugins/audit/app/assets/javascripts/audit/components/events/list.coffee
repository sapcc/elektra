#= require audit/components/events/item
#= require audit/components/events/item_details


# import
{ div, span, label, i, input, table, thead, tbody, tr, th, td } = React.DOM
{ connect } = ReactRedux
{ EventItem, EventItemDetails, filterEventsStartTime, filterEventsEndTime } = audit

Events = ({events, isFetching, loadEvents, filterEventsStartTime, filterEventsEndTime, filterStartTime, filterEndTime}) ->
  div null,
    div className: 'toolbar toolbar-controlcenter',
      label null, 'Time range:'
      React.createElement Datetime, value: filterStartTime, inputProps: {placeholder: 'Select start time'}, isValidDate: AuditHelpers.isValidDate, onChange: ((e) -> filterEventsStartTime(e))
      span className: 'toolbar-input-divider', '\u2013' # EN DASH: &ndash;
      React.createElement Datetime, value: filterEndTime, inputProps: {placeholder: 'Select end time'}, isValidDate: AuditHelpers.isValidDate, onChange: ((e) -> filterEventsEndTime(e))



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
    filterStartTime:  state.filterStartTime
    filterEndTime:    state.filterEndTime
  (dispatch) ->
    filterEventsStartTime: (filterStartTime) -> dispatch(filterEventsStartTime(filterStartTime))
    filterEventsEndTime: (filterEndTime) -> dispatch(filterEventsEndTime(filterEndTime))


)(Events)


# export
audit.EventList = Events
