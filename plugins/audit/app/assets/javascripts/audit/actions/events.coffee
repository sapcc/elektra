((app) ->
  #################### EVENTS #########################

  requestEvents = () ->
    type: app.REQUEST_EVENTS

  requestEventsFailure = (error) ->
    type: app.REQUEST_EVENTS_FAILURE
    error: error

  receiveEvents = (json, total) ->
    type: app.RECEIVE_EVENTS
    events: json
    total: total

  loadEvents = () ->
    (dispatch, getState) ->
      currentState    = getState()
      events          = currentState.events
      limit           = events.limit
      offset          = events.offset
      isFetching      = events.isFetching
      filterType      = events.filterType
      filterTerm      = events.filterTerm
      filterStartTime = events.filterStartTime
      filterEndTime   = events.filterEndTime


      dispatch(requestEvents())
      return if isFetching # don't fetch if we're already fetching

      app.ajaxHelper.get '/events',
        data: {
          limit: limit
          offset: offset
          time: AuditDataFormatter.buildTimeFilter(filterStartTime, filterEndTime)
        }
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveEvents(data["events"],data["total"]))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestEventsFailure(errorThrown))



  fetchEvents = (offset) ->
    (dispatch) ->
      dispatch(updateOffset(offset))
      dispatch(loadEvents())

  updateOffset = (offset)->
    type: app.UPDATE_OFFSET
    offset: offset


  # ----------- FILTERS -----------

  updateFilterStartTime = (filterStartTime) ->
    type: app.UPDATE_FILTER_START_TIME
    filterStartTime: filterStartTime

  filterEventsStartTime = (filterStartTime) ->
    (dispatch) ->
      # trigger api call only if the given start time is a valid date or empty string
      if moment(filterStartTime).isValid() || ReactHelpers.isEmptyString(filterStartTime)
        dispatch(updateFilterStartTime(filterStartTime))
        dispatch(loadEvents())
      # TODO: Add else case with validation error display for user

  updateFilterEndTime = (filterEndTime) ->
    type: app.UPDATE_FILTER_END_TIME
    filterEndTime: filterEndTime

  filterEventsEndTime = (filterEndTime) ->
    (dispatch) ->
      # trigger api call only if the given start time is a valid date or empty string
      if moment(filterEndTime).isValid() || ReactHelpers.isEmptyString(filterEndTime)
        dispatch(updateFilterEndTime(filterEndTime))
        dispatch(loadEvents())
      # TODO: Add else case with validation error display for user



  # ----------- EVENT DETAILS -----------

  toggleEventDetails = (event) ->
    (dispatch) ->
      dispatch(toggleEventDetailsVisible(event))
      unless event.details # fetch details if we don't have them yet
        dispatch(loadEventDetails(event))


  toggleEventDetailsVisible = (event) ->
    type: app.TOGGLE_EVENT_DETAILS_VISIBLE
    eventId: event.event_id
    detailsVisible: !event.detailsVisible


  loadEventDetails = (event) ->
    (dispatch, getState) ->

      return if event.isFetchingDetails # don't fetch if we're already fetching
      dispatch(requestEventDetails(event))

      app.ajaxHelper.get "/events/#{event.event_id}",
        data: {}
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveEventDetails(event, data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestEventDetailsFailure(event, errorThrown))


  requestEventDetails = (event) ->
    type: app.REQUEST_EVENT_DETAILS
    eventId: event.event_id

  requestEventDetailsFailure = (event, error) ->
    type: app.REQUEST_EVENT_DETAILS_FAILURE
    error: error
    eventId: event.event_id

  receiveEventDetails = (event, json) ->
    type: app.RECEIVE_EVENT_DETAILS
    eventDetails: json
    eventId: event.event_id









  # export
  app.fetchEvents                 = fetchEvents
  app.filterEventsStartTime       = filterEventsStartTime
  app.filterEventsEndTime         = filterEventsEndTime
  app.toggleEventDetails          = toggleEventDetails

)(audit)
