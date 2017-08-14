
# import
{ li, a } = React.DOM
{ connect } = ReactRedux
{ paginate } = audit


Page = ({
  page,
  label,
  markAsActive,
  disabled,
  currentPage,
  handlePageChange
}) ->

  className = ''
  if disabled
    className += 'disabled '
  if page == currentPage && markAsActive
    className += 'active '


  li className: className,
    a href: "#", onClick: ((e) -> e.preventDefault(); handlePageChange(page)),
      if label then label else page



Page = connect(
  (state) ->
      currentPage: state.events.currentPage

  (dispatch) ->
    handlePageChange: (page) -> dispatch(paginate(page))


)(Page)


# export
audit.Page = Page
