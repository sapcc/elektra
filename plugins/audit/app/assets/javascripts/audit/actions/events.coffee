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
      currentState = getState()
      limit = currentState.events.limit
      offset= currentState.events.offset
      isFetching = currentState.events.isFetching
      filterType= currentState.events.filterType
      filterTerm= currentState.events.filterTerm

      dispatch(requestEvents())
      data = {
        "next": "http://{hermes_host}:8788/v1/events?limit=2&offset=3",
        "previous": "http://{hermes_host}:8788/v1/events?limit=2&offset=0",
        "events": [
          {
            "source": "identity",
            "event_id": "3824e534-6cd4-53b2-93d4-33dc4ab50b8c",
            "event_type": "identity.project.created",
            "event_time": "2017-04-20T11:27:15.834562+0000",
            "resource_name": "temp_project",
            "resource_id": "3a7e3d2421384f56a8fb6cf082a8efab",
            "resource_type": "data/security/project",
            "initiator": {
              "domain_id": "39a253e16e4a4a3686edca72c8e101bc",
              "domain_name": "monsoon3",
              "typeURI": "service/security/account/user",
              "user_id": "275e9a16294b3805c8dd2ab77123531af6aacd92182ddcd491933e5c09864a1d",
              "user_name": "I056593",
              "host": {
                 "agent": "python-keystoneclient",
                 "address": "100.66.0.24"
              }
            }
          },
          {
            "source": "identity",
            "event_id": "1ff4703a-d8c3-50f8-94d1-8ab382941e80",
            "event_type": "identity.project.deleted",
            "event_time": "2017-04-20T11:28:32.521298+0000",
            "resource_name": "temp_project",
            "resource_id": "3a7e3d2421384f56a8fb6cf082a8efab",
            "resource_type": "data/security/project",
            "initiator": {
              "domain_id": "39a253e16e4a4a3686edca72c8e101bc",
              "domain_name": "monsoon3",
              "typeURI": "service/security/account/user",
              "user_id": "275e9a16294b3805c8dd2ab77123531af6aacd92182ddcd491933e5c09864a1d",
              "user_name": "I056593",
              "host": {
                 "agent": "python-keystoneclient",
                 "address": "100.66.0.24"
              }
            }    }
        ],
        "total": 5
      }
      setTimeout((() -> dispatch(receiveEvents(data["events"],data["total"]))), 1000)


      return if isFetching
      # app.ajaxHelper.get '/events',
      #   data: {limit: limit, offset: offset}
      #   success: (data, textStatus, jqXHR) ->
      #     dispatch(offset,receiveEvents(data))
      #   error: ( jqXHR, textStatus, errorThrown) ->
      #     dispatch(requestEventsFailure())


  fetchEvents= (offset) ->
    (dispatch) ->
      dispatch(updateOffset(offset))
      dispatch(loadEvents())

  updateOffset=(offset)->
    type: app.UPDATE_OFFSET
    offset: offset

  updateFilter=(eventType,eventTerm)->
    type: app.UPDATE_FILTER
    eventType: eventType
    eventTerm: eventTerm

  filterEvents=(filterType,filterTerm) ->
    (dispatch) ->
      dispatch(updateFilter(filterType,filterTerm))
      dispatch(loadEvents())

  # export
  app.fetchEvents                  = fetchEvents
  app.filterEvents                 = filterEvents

)(audit)
