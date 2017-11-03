#= require audit/components/events/item
#= require audit/components/events/item_details
#= require audit/components/shared/pagination


# import
{ div, span, label, select, option, input, i, table, thead, tbody, tr, th, td, a } = React.DOM
{ connect } = ReactRedux
{ EventItem, EventItemDetails, filterEventsStartTime, filterEventsEndTime, filterEventsFilterType, filterEventsFilterTerm, clearFilters, Pagination } = audit


Events = ({
  events,
  isFetching,
  loadEvents,
  handleStartTimeChange,
  handleEndTimeChange,
  handleFilterTypeChange,
  handleFilterTermChange,
  handleClearFilters,
  filterStartTime,
  filterEndTime,
  filterType,
  filterTerm,
  attributeValues,
  isFetchingAttributeValues,
  offset,
  limit,
  total,
  error
}) ->

  div null,
    div className: 'toolbar toolbar-controlcenter',
      label null, 'Filter:'
      div className: 'inputwrapper',
        select name: 'filterType', className: 'form-control', value: filterType, onChange: ((e) -> handleFilterTypeChange(e.target.value)),
          option value: '', 'Select attribute '
          option value: 'observer_type',  'Source'
          option value: 'action', 'Action'
          option value: 'target_type', 'Resource Type'
          option value: 'target_id', 'Resource ID'
          option value: 'initiator_id', 'Initiator/User ID'
          option value: 'initiator_type', 'Initiator Type'
          option value: 'outcome', 'Result'
 
      div className: 'inputwrapper',
        if attributeValues[filterType] && attributeValues[filterType].length > 0
          select name: 'filterTerm', className: 'form-control filter-term', value: filterTerm, onChange: ((e) -> handleFilterTermChange(e.target.value, 0)),
            option value: '', 'Select'
            for attribute in attributeValues[filterType]
              option value: attribute, key: "filterTerm_#{attribute}", attribute
        else
          input name: 'filterTerm', className: 'form-control filter-term', value: filterTerm, placeholder: 'Enter lookup value', disabled: ReactHelpers.isEmpty(filterType) || isFetchingAttributeValues, onChange: ((e) -> handleFilterTermChange(e.target.value, 500))
      span className: 'toolbar-input-divider'

      label null, 'Time range:'
      React.createElement Datetime, value: filterStartTime, inputProps: {placeholder: 'Select start time'}, isValidDate: AuditHelpers.isValidDate, onChange: ((e) -> handleStartTimeChange(e))
      span className: 'toolbar-input-divider', '\u2013' # EN DASH: &ndash;
      React.createElement Datetime, value: filterEndTime, inputProps: {placeholder: 'Select end time'}, isValidDate: AuditHelpers.isValidDate, onChange: ((e) -> handleEndTimeChange(e))


      if filterTerm or filterEndTime or filterStartTime
        a className: 'clear-all', href: '#', onClick: ((e) -> e.preventDefault(); handleClearFilters()),
          i className: 'fa fa-times-circle'
          "Clear filters"



    table className: 'table',
      thead null,
        tr null,
          th className: 'icon-cell', ''
          th null, 'Time'
          th null, 'Source'
          th null, 'Action'
          th null, 'Target Resource'
          th className: 'user-cell', 'Initiator/User'

      if error
        tbody null,
          tr null,
            td colSpan: '6',
              error
      else
        if events
          for event in events
            tbody key: event.id,
              React.createElement EventItem, event: event
              if event.detailsVisible
                React.createElement EventItemDetails, event: event
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


    React.createElement Pagination, offset: offset, limit: limit, total: total

Events = connect(
  (state) ->
    filterStartTime:            state.events.filterStartTime
    filterEndTime:              state.events.filterEndTime
    filterType:                 state.events.filterType
    filterTerm:                 state.events.filterTerm
    attributeValues:            state.events.attributeValues
    isFetchingAttributeValues:  state.events.isFetchingAttributeValues
    offset:                     state.events.offset
    limit:                      state.events.limit
    total:                      state.events.total
    error:                      state.events.error
  (dispatch) ->
    handleStartTimeChange:      (filterStartTime)     -> dispatch(filterEventsStartTime(filterStartTime))
    handleEndTimeChange:        (filterEndTime)       -> dispatch(filterEventsEndTime(filterEndTime))
    handleFilterTypeChange:     (filterType)          -> dispatch(filterEventsFilterType(filterType))
    handleFilterTermChange:     (filterTerm, timeout) -> dispatch(filterEventsFilterTerm(filterTerm, timeout))
    handleClearFilters:         ()                    -> dispatch(clearFilters())
)(Events)

# export
audit.EventList = Events
