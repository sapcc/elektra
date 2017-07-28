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


      return if isFetching # don't fetch if we're already fetching
      dispatch(requestEvents())

      app.ajaxHelper.get '/events',
        data: {
          limit: limit
          offset: offset
          time: AuditDataFormatter.buildTimeFilter(filterStartTime, filterEndTime)
          "#{filterType}": filterTerm
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
      # trigger api call only if the given start time is a valid date or an empty string
      if moment.isMoment(filterStartTime) || ReactHelpers.isEmpty(filterStartTime)
        dispatch(updateFilterStartTime(filterStartTime))
        dispatch(loadEvents())
      # TODO: Add else case with validation error display for user

  updateFilterEndTime = (filterEndTime) ->
    type: app.UPDATE_FILTER_END_TIME
    filterEndTime: filterEndTime

  filterEventsEndTime = (filterEndTime) ->
    (dispatch) ->
      # trigger api call only if the given start time is a valid date or an empty string
      if moment.isMoment(filterEndTime) || ReactHelpers.isEmpty(filterEndTime)
        dispatch(updateFilterEndTime(filterEndTime))
        dispatch(loadEvents())
      # TODO: Add else case with validation error display for user


  updateFilterType = (filterType) ->
    type: app.UPDATE_FILTER_TYPE
    filterType: filterType

  filterEventsFilterType = (filterType) ->
    (dispatch) ->
      dispatch(updateFilterType(filterType))
      dispatch(filterEventsFilterTerm('', 0)) # reset filter term on filter type change
      dispatch(fetchAttributeValues(filterType))
      # if filterType empty, loadEvents with empty filter
      # else

  updateFilterTerm = (filterTerm) ->
    type: app.UPDATE_FILTER_TERM
    filterTerm: filterTerm

  # initialize timeout for term filter
  filterTermTimeout = null

  filterEventsFilterTerm = (filterTerm, timeout) ->
    clearTimeout(filterTermTimeout) # reset timeout
    console.log("timeout: #{timeout}")
    (dispatch) ->
      dispatch(updateFilterTerm(filterTerm))
      # load events only if no new user input has happened during the specified timout window
      filterTermTimeout = setTimeout((() -> dispatch(loadEvents())), timeout)


  # ----------- ATTRIBUTE VALUES -----------

  requestAttributeValues = () ->
    type: app.REQUEST_ATTRIBUTE_VALUES

  requestAttributeValuesFailure = (error) ->
    type: app.REQUEST_ATTRIBUTE_VALUES_FAILURE
    error: error

  requestAttributeValuesNotFound = (attribute) ->
    type: app.REQUEST_ATTRIBUTE_VALUES_NOT_FOUND
    attribute: attribute

  receiveAttributeValues = (attribute, json) ->
    type: app.RECEIVE_ATTRIBUTE_VALUES
    values: json
    attribute: attribute


  fetchAttributeValues = (attribute) ->
    (dispatch) ->
      dispatch(loadAttributeValues(attribute))

  loadAttributeValues = (attribute) ->
    (dispatch, getState) ->
      currentState    = getState()
      events          = currentState.events
      attributeValues = events.attributeValues

      return if attributeValues[attribute] # don't fetch if we already have the values
      dispatch(requestAttributeValues())

      app.ajaxHelper.get "/attributes/#{attribute}",
        data: {}
        success: (data, textStatus, jqXHR) ->
          console.log(data)
          dispatch(receiveAttributeValues(attribute, data))
        error: ( jqXHR, textStatus, errorThrown) ->
          if jqXHR.status == 404
            dispatch(requestAttributeValuesNotFound(attribute))
          else
            dispatch(requestAttributeValuesFailure(jqXHR.responseText))



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
  app.filterEventsFilterType      = filterEventsFilterType
  app.filterEventsFilterTerm      = filterEventsFilterTerm
  app.toggleEventDetails          = toggleEventDetails

)(audit)
