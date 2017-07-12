#= require audit/components/events/item
#= require audit/components/events/item_details


# import
{ div, span, label, select, option, input, i, table, thead, tbody, tr, th, td } = React.DOM
{ connect } = ReactRedux
{ EventItem, EventItemDetails, filterEventsStartTime, filterEventsEndTime, filterEventsFilterType } = audit

Events = ({events, isFetching, loadEvents, handleStartTimeChange, handleEndTimeChange, handleFilterTypeChange, filterStartTime, filterEndTime, filterType, filterTerm}) ->
  div null,
    div className: 'toolbar toolbar-controlcenter',
      label null, 'Filter:'
      div className: 'inputwrapper',
        select name: 'filterType', className: 'form-control', value: filterType, onChange: ((e) -> handleFilterTypeChange(e.target.value)),
          option value: '', 'Select attribute '
          option value: 'source',  'Source'
          option value: 'event_type', 'Event Type'
          option value: 'resource_type', 'Resource Type'
          option value: 'user_name', 'User ID'

      div className: 'inputwrapper',
        input className: 'form-control', value: filterTerm, placeholder: 'Enter lookup value'
      span className: 'toolbar-input-divider'

      label null, 'Time range:'
      React.createElement Datetime, value: filterStartTime, inputProps: {placeholder: 'Select start time'}, isValidDate: AuditHelpers.isValidDate, onChange: ((e) -> handleStartTimeChange(e))
      span className: 'toolbar-input-divider', '\u2013' # EN DASH: &ndash;
      React.createElement Datetime, value: filterEndTime, inputProps: {placeholder: 'Select end time'}, isValidDate: AuditHelpers.isValidDate, onChange: ((e) -> handleEndTimeChange(e))



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
    filterType:       state.filterType
  (dispatch) ->
    handleStartTimeChange:  (filterStartTime) -> dispatch(filterEventsStartTime(filterStartTime))
    handleEndTimeChange:    (filterEndTime)   -> dispatch(filterEventsEndTime(filterEndTime))
    handleFilterTypeChange: (filterType)      -> dispatch(filterEventsFilterType(filterType))


)(Events)


# export
audit.EventList = Events
