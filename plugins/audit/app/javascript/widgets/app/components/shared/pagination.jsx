import Page from "../../containers/shared/page"

export default ({ offset, limit, total, currentPage, handlePageChange }) => {
  let pages = Math.ceil(total / limit)
  // how many pages do we want to show around the current page. should be an
  // odd number, the current page will take the middle spot and the remainder
  // will be added before and after
  let paginationWindowSize = 5
  // number of pages before and after the current page
  let padding = Math.floor(paginationWindowSize / 2)

  // determine start page according to configured sliding window size.
  // The Math.min expression is for the case that currentPage is near the end
  // of the page list. We want to ensure that we show at least
  // paginationWindowSize pages at the end. If we went with
  // Math.max(1, currentPage - padding) we would show padding pages
  //(=less than half paginationWindowSize)
  let startPage = Math.max(
    1,
    Math.min(currentPage - padding, pages - paginationWindowSize + 1)
  )
  // end page is similar. at max it is the last page. The Math.max expression
  // is for the case where currentPage is near the start of the list.
  // We want to ensure that we show at least paginationWindowSize pages
  let endPage = Math.min(
    pages,
    Math.max(currentPage + padding, paginationWindowSize)
  )

  // If there are only 1 or 2 pages before the calculated start page,
  // set startPage to 1
  if (startPage > 1 && startPage < 4) startPage = 1

  // If there are only 1 or 2 pages after the calculated end page, set
  // endPage to last page
  if (endPage < pages && endPage > pages - 3) endPage = pages

  // preliminary pages array
  let pageWindow = Array.from(
    new Array(endPage - startPage + 1),
    (x, i) => startPage + i
  )
  // let pageWindow = [startPage..endPage]

  // if page window is somewhere in the middle of the page list add first
  // and last page and ellipsis as applicable
  if (startPage > 1) {
    pageWindow = [
      1,
      { page: "ellipsis-start", label: "...", disabled: true },
    ].concat(pageWindow)
  }
  if (endPage < pages) {
    pageWindow = pageWindow.concat([
      { page: "ellipsis-end", label: "...", disabled: true },
      pages,
    ])
  }

  if (pages <= 1) return null

  return (
    <nav>
      <ul className="pagination">
        <Page
          page={currentPage - 1}
          label="Previous"
          disabled={currentPage == 1}
          key="page-previous"
        />
        {pageWindow.map((page) =>
          typeof page === "object" ? (
            <Page
              page={page["page"]}
              label={page["label"]}
              disabled={page["disabled"]}
              key={`page-${page["page"]}`}
            />
          ) : (
            <Page page={page} key={`page-${page}`} />
          )
        )}
        <Page
          page={currentPage + 1}
          label="Next"
          disabled={currentPage == pages}
          key="page-next"
        />
      </ul>
    </nav>
  )
}
