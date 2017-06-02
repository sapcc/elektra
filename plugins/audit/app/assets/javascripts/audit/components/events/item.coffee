# import

{ div, button, span, a, i, br} = React.DOM

Event = React.createClass
  getInitialState: (e) ->
    isShown: false

  toggleInfos: () ->
    if @state.isShown
      @setState(isShown: false)
    else
      @setState(isShown: true)

  render: () ->
    event = @props.event
    div className: 'event',
      div className: 'event-cell event-data',
        moment(event.event_time).format("YYYY-MM-DD, HH:mm:ssZZ")
      div className: 'event-cell event-data',
        event.source
      div className: 'event-cell event-data',
        event.event_type
        # a href: 'javascript:void(0)', onClick: @toggleInfos,
        #   i className: 'fa fa-caret-down', null
        # if @state.isShown
        #   span null, 'More Infos'
        # else
        #   null
      div className: 'event-cell event-data big-data-cell',
        event.resource_type
        br null
        span className: 'resource-id', event.resource_id
        br null
        event.resource_name
      div className: 'event-cell event-data big-data-cell',
        if event.initiator.user_name && event.initiator.user_name.length > 0
          event.initiator. user_name
        else
          span className: 'resource-id', event.initiator.user_id


# export
audit.EventItem = Event
