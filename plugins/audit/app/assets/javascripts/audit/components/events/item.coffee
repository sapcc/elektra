# import

{ div, button, span, a, i, br, tr, td} = React.DOM
{ connect } = ReactRedux
{ toggleEventDetails } = audit


Event = ({event, toggleDetails}) ->
  showDetailsClassName = if event.detailsVisible then 'fa fa-caret-down' else 'fa fa-caret-right'
  tr null,
    td null,
      a href: '#', onClick: ((e) -> e.preventDefault(); toggleDetails(event)),
        i className: showDetailsClassName, null
    td null,
      moment(event.event_time).format("YYYY-MM-DD, HH:mm:ssZZ")
    td null,
      event.source
    td null,
      event.event_type
    td className: 'big-data-cell',
      event.resource_type
      br null
      span className: 'resource-id', event.resource_id
      br null
      event.resource_name
    td className: 'big-data-cell',
      if event.initiator.user_name && event.initiator.user_name.length > 0
        event.initiator. user_name
      else
        span className: 'resource-id', event.initiator.user_id


Event = connect(
  (state) ->
  (dispatch) ->
    toggleDetails: (event) -> dispatch(toggleEventDetails(event))
)(Event)


# export
audit.EventItem = Event
