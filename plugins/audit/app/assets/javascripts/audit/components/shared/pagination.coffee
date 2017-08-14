#= require audit/components/shared/page

# import
{ nav, ul, li, a, span } = React.DOM
{ connect } = ReactRedux
{ Page, paginate } = audit


Pagination = ({
  offset,
  limit,
  total,
  currentPage,
  handlePageChange
}) ->

  pages = Math.ceil(total / limit)

  if pages > 1
    nav null,
      ul className: "pagination",
        React.createElement Page, page: (currentPage - 1), label: "Previous", markAsActive: false, disabled: (currentPage == 1)
        for page in [1..pages]
          React.createElement Page, page: page, markAsActive: true, key: "page-#{page}"

        React.createElement Page, page: (currentPage + 1), label: "Next", markAsActive: false, disabled: (currentPage == pages)
  else
    null




Pagination = connect(
  (state) ->
    offset:       state.events.offset
    limit:        state.events.limit
    total:        state.events.total
    currentPage:  state.events.currentPage

  (dispatch) ->


)(Pagination)


# export
audit.Pagination = Pagination
