((app) ->
  ########################### SHARES ##############################
  initialEventState =
    error: null
    offset: 0
    limit: 20
    filterType:null
    filterTerm: null
    items: []
    isFetching: false

  updateFilter=(state,{filterType,filterTerm}) ->
    ReactHelpers.mergeObjects({},state,{
      filterType: filterType,
      filterTerm: filterTerm,
      offset: 0
    })

  requestEvents = (state,{requestedAt}) ->
    ReactHelpers.mergeObjects({},state,{
      isFetching: true
    })

  requestEventsFailure=(state,{error})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false,
      error: error
    })

  receiveEvents=(state,{events,offset})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: false
      items: events
      error: null
      offset: offset
    })

  # shares reducer
  app.events = (state = initialEventState, action) ->
    switch action.type
      when app.REQUEST_EVENTS then requestEvents(state,action)
      when app.RECEIVE_EVENTS then receiveEvents(state,action)
      when app.REQUEST_EVENTS_FAILURE then requestEventsFailure(state,action)
      when app.UPDATE_FILTER then updateFilter(state,action)
      else state

)(audit)
