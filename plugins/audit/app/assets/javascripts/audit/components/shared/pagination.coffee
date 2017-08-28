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
  paginationWindowSize = 5 # how many pages do we want to show around the current page. should be an odd number, the current page will take the middle spot and the remainder will be added before and after
  padding = Math.floor(paginationWindowSize/2) # number of pages before and after the current page

  # determine start page according to configured sliding window size. The Math.min expression is for the case that currentPage is near the end of the page list. We want to ensure that we show at least paginationWindowSize pages at the end. If we went with Math.max(1, currentPage - padding) we would show padding pages (=less than half paginationWindowSize)
  # end page is similar. at max it is the last page. The Math.max expression is for the case where currentPage is near the start of the list. We want to ensure that we show at least paginationWindowSize pages
  startPage = Math.max(1, Math.min(currentPage - padding, pages - paginationWindowSize + 1))
  endPage   = Math.min(pages, Math.max(currentPage + padding, paginationWindowSize))

  # If there are only 1 or 2 pages before the calculated start page, set startPage to 1
  if startPage > 1 && startPage < 4
    startPage = 1

  # If there are only 1 or 2 pages after the calculated end page, set endPage to last page
  if endPage < pages && endPage > pages - 3
    endPage = pages



  # preliminary pages array
  pageWindow = [startPage..endPage]

  # if page window is somewhere in the middle of the page list add first and last page and ellipsis as applicable
  if startPage > 1
    pageWindow = [1, {page: 'ellipsis-start', label: '...', disabled: true}].concat(pageWindow)
  if endPage < pages
    pageWindow = pageWindow.concat([{page: 'ellipsis-end', label: '...', disabled: true}, pages])


  if pages > 1
    nav null,
      ul className: "pagination",
        React.createElement Page, page: (currentPage - 1), label: "Previous", disabled: (currentPage == 1), key: "page-previous"


        for page in pageWindow
          if typeof page is 'object'
            React.createElement Page, page: page['page'], label: page['label'], disabled: page['disabled'], key: "page-#{page['page']}"
          else
            React.createElement Page, page: page, key: "page-#{page}"



        React.createElement Page, page: (currentPage + 1), label: "Next", disabled: (currentPage == pages), key: "page-next"
  else
    null




Pagination = connect(
  (state) ->
    offset:       state.events.offset
    limit:        state.events.limit
    total:        state.events.total
    currentPage:  state.events.currentPage
)(Pagination)


# export
audit.Pagination = Pagination
