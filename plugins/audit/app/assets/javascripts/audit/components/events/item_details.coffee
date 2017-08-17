# import

{ div, button, span, pre, a, i, br, tr, td} = React.DOM
{ connect } = ReactRedux


EventDetails = ({event}) ->
  tr null,
    td  colSpan: '6',
    if event.isFetchingDetails
      span className: 'spinner'
    else
      pre null,
        JSON.stringify(event.details, null, 2)




# export
audit.EventItemDetails = EventDetails
