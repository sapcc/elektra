((app) ->
  ########################### EVENTS ##############################
  initialEventState =
    error: null
    total: 0
    offset: 0
    limit: 20
    filterType:null
    filterTerm: null
    items: []
    isFetching: false

  updateFilter=(state,{filterType,filterTerm}) ->
    ReactHelpers.mergeObjects({},state,{
      filterType: filterType,
      filterTerm: filterTerm
    })

  updateOffset=(state,{offset}) ->
    ReactHelpers.mergeObjects({},state,{
      offset: offset
    })

  requestEvents = (state,{}) ->
    ReactHelpers.mergeObjects({},state,{
      isFetching: true
    })

  requestEventsFailure=(state,{error})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false,
      error: error
    })

  receiveEvents=(state,{events,total})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: events
      error: null
    })


  # Event Details
  
  toggleEventDetailsVisible= (state,{eventId, detailsVisible}) ->
    index = ReactHelpers.findIndexInArray(state.items,eventId, 'event_id')
    return state if index<0

    newState = ReactHelpers.cloneHashMap(state)
    newState.items[index].detailsVisible = detailsVisible
    newState


  # events reducer
  app.events = (state = initialEventState, action) ->
    switch action.type
      when app.REQUEST_EVENTS then requestEvents(state,action)
      when app.RECEIVE_EVENTS then receiveEvents(state,action)
      when app.REQUEST_EVENTS_FAILURE then requestEventsFailure(state,action)
      when app.UPDATE_FILTER then updateFilter(state,action)
      when app.UPDATE_OFFSET then updateOffset(state,action)
      when app.TOGGLE_EVENT_DETAILS_VISIBLE then toggleEventDetailsVisible(state,action)
      else state

)(audit)
