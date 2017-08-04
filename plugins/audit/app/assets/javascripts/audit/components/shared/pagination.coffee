
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
  currentPage = if offset > 0 then (offset / limit) else 1
  console.log("offset: #{offset} -- limit: #{limit} -- total: #{total} -- pages: #{pages} -- currentPage: #{currentPage}")

  if pages > 1
    nav null,
      ul className: "pagination",
        li null,
          a href: "#",
            span null, "Previous"
        for page in [1..pages]
          console.log("page: #{page} -- currentPage: #{currentPage}")
          li className: ('active' if page == currentPage), key: "page-#{page}",
            a href: "#", onClick: ((e) -> e.preventDefault(); handlePageChange(page)),
              page

        li null,
          a href: "#",
            span null, "Next"
  else
    null




Pagination = connect(
  (state) ->
    offset: state.events.offset
    limit:  state.events.limit
    total:  state.events.total

  (dispatch) ->
    handlePageChange: (page) -> dispatch(filterPaginationStartTime(filterStartTime))


)(Pagination)


# export
audit.Pagination = Pagination
