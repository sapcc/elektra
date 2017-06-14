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
      limit         = currentState.events.limit
      offset        = currentState.events.offset
      isFetching    = currentState.events.isFetching
      filterType    = currentState.events.filterType
      filterTerm    = currentState.events.filterTerm


      dispatch(requestEvents())
      return if isFetching # don't fetch if we're already fetching
      app.ajaxHelper.get '/events',
        data: {limit: limit, offset: offset}
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveEvents(data["events"],data["total"]))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestEventsFailure())



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
    (dispatch,getState) ->
      currentState = getState()
      dispatch(toggleEventDetailsVisible(event))


  toggleEventDetailsVisible= (event) ->
    type: app.TOGGLE_EVENT_DETAILS_VISIBLE
    eventId: event.event_id
    detailsVisible: !event.detailsVisible





  # export
  app.fetchEvents                 = fetchEvents
  app.filterEvents                = filterEvents
  app.toggleEventDetails          = toggleEventDetails

)(audit)
