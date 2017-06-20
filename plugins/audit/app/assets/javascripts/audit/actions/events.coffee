((app) ->
  #################### EVENTS #########################
  requestEvents= () ->
    type: app.REQUEST_EVENTS

  requestEventsFailure= (error) ->
    type: app.REQUEST_EVENTS_FAILURE
    error: error

  receiveEvents= (json,total) ->
    type: app.RECEIVE_EVENTS
    events: json
    total: total

  loadEvents= () ->
    (dispatch,getState) ->
      currentState  = getState()
      events        = currentState.events
      limit         = events.limit
      offset        = events.offset
      isFetching    = events.isFetching
      filterType    = events.filterType
      filterTerm    = events.filterTerm


      dispatch(requestEvents())
      return if isFetching # don't fetch if we're already fetching
      app.ajaxHelper.get '/events',
        data: {limit: limit, offset: offset}
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveEvents(data["events"],data["total"]))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestEventsFailure(errorThrown))



  fetchEvents= (offset) ->
    (dispatch) ->
      dispatch(updateOffset(offset))
      dispatch(loadEvents())

  updateOffset=(offset)->
    type: app.UPDATE_OFFSET
    offset: offset

  updateFilter=(eventType, eventTerm)->
    type: app.UPDATE_FILTER
    eventType: eventType
    eventTerm: eventTerm

  filterEvents=(filterType, filterTerm) ->
    (dispatch) ->
      dispatch(updateFilter(filterType,filterTerm))
      dispatch(loadEvents())




  # EVENT DETAILS

  toggleEventDetails= (event) ->
    (dispatch) ->
      dispatch(toggleEventDetailsVisible(event))
      unless event.details
        # fetch details if we don't have them yet
        dispatch(loadEventDetails(event))



  toggleEventDetailsVisible= (event) ->
    type: app.TOGGLE_EVENT_DETAILS_VISIBLE
    eventId: event.event_id
    detailsVisible: !event.detailsVisible


  loadEventDetails= (event) ->
    (dispatch,getState) ->

      return if event.isFetchingDetails # don't fetch if we're already fetching

      dispatch(requestEventDetails(event))

      app.ajaxHelper.get "/events/#{event.event_id}",
        data: {}
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveEventDetails(event, data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestEventDetailsFailure(event, errorThrown))


  requestEventDetails= (event) ->
    type: app.REQUEST_EVENT_DETAILS
    eventId: event.event_id

  requestEventDetailsFailure= (event, error) ->
    type: app.REQUEST_EVENT_DETAILS_FAILURE
    error: error
    eventId: event.event_id

  receiveEventDetails= (event, json) ->
    type: app.RECEIVE_EVENT_DETAILS
    eventDetails: json
    eventId: event.event_id









  # export
  app.fetchEvents                 = fetchEvents
  app.filterEvents                = filterEvents
  app.toggleEventDetails          = toggleEventDetails

)(audit)
