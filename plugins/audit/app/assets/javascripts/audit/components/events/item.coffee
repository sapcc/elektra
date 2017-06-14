# import

{ div, button, span, a, i, br} = React.DOM
{ connect } = ReactRedux
{ toggleEventDetails } = audit


Event = ({event, toggleDetails}) ->
  # = React.createClass
  # getInitialState: (e) ->
  #   isShown: false
  #
  # toggleInfos: () ->
  #   if @state.isShown
  #     @setState(isShown: false)
  #   else
  #     @setState(isShown: true)

  # render: () ->
  # event = @props.event

  showDetailsClassName = if event.detailsVisible then 'fa fa-caret-down' else 'fa fa-caret-right'
  div className: 'event',
    div className: 'event-cell',
      a href: '#', onClick: ((e) -> e.preventDefault(); toggleDetails(event)),
        i className: showDetailsClassName, null
      # if @state.isShown
      #   span null, 'More Infos'
      # else
      #   null
    div className: 'event-cell',
      moment(event.event_time).format("YYYY-MM-DD, HH:mm:ssZZ")
    div className: 'event-cell',
      event.source
    div className: 'event-cell',
      event.event_type
    div className: 'event-cell big-data-cell',
      event.resource_type
      br null
      span className: 'resource-id', event.resource_id
      br null
      event.resource_name
    div className: 'event-cell big-data-cell',
      if event.initiator.user_name && event.initiator.user_name.length > 0
        event.initiator. user_name
      else
        span className: 'resource-id', event.initiator.user_id

    # if @state.isShown
    #   div className: 'event-details',
    #       span null, 'Here be the Details'

    if event.detailsVisible
      div className: 'event-details',
          span null, 'Here be the Details'


Event = connect(
  (state) ->
  (dispatch) ->
    toggleDetails: (event) -> dispatch(toggleEventDetails(event))
)(Event)


# export
audit.EventItem = Event
