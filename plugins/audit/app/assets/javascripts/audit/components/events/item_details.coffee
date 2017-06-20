# import

{ div, button, span, pre, a, i, br, tr, td} = React.DOM
{ connect } = ReactRedux
# { toggleEventDetails } = audit


EventDetails = ({event}) ->
  tr null,
    td  colSpan: '6',
    if event.isFetchingDetails
      span className: 'spinner'
    else
      pre null,
        JSON.stringify(event.details, null, 2)




# Event = connect(
#   (state) ->
#   (dispatch) ->
#     toggleDetails: (event) -> dispatch(toggleEventDetails(event))
# )(Event)


# export
audit.EventItemDetails = EventDetails
