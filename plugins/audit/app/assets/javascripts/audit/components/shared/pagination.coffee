
# import
{ nav, ul, li, a, span } = React.DOM
{ connect } = ReactRedux
{  } = audit


Pagination = ({
  offset,
  limit,
  total
}) ->

  pages = Math.ceil(total / limit)

  nav null,
    ul className: "pagination",
      li null,
        a href: "#",
          span null, "Previous"
      for page in [1..pages]
        li key: "page-#{page}",
          a href: "#",
            page

      li null,
        a href: "#",
          span null, "Next"




Pagination = connect(
  (state) ->

  (dispatch) ->
    handleStartTimeChange:          (filterStartTime)     -> dispatch(filterPaginationStartTime(filterStartTime))


)(Pagination)


# export
audit.Pagination = Pagination
