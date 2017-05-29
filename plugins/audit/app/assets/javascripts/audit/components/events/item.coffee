# import

{ tr,td, div, button, span, a, i} = React.DOM

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
    tr null,
      td null,
        event.event_type
        a href: 'javascript:void(0)', onClick: @toggleInfos,
          i className: 'fa fa-caret-down', null
        if @state.isShown
          span null, 'More Infos'
        else
          null
      td null, event.resource_name


# export
audit.EventItem = Event
