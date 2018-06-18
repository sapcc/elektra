export const Pagination = (props) => {
  if(!props.total || props.total<=props.perPage) return null;

  const pageCount = Math.ceil(props.total / props.perPage)
  const pageWindow = props.pageWindow || 10
  const showPrev = props.currentPage > 1
  const showNext = props.currentPage < pageCount


  let startPage = Math.floor(props.currentPage - pageWindow/2)
  if(startPage < 1) startPage = 1
  let endPage = Math.ceil(startPage + pageWindow - 1)
  if(endPage > pageCount) endPage = pageCount
  if((endPage - startPage) < 10 && (endPage - pageWindow + 1) > 1 ) {
    startPage = (endPage - pageWindow + 1)
  }

  let pages = []
  for(let i=startPage; i<=endPage; i++) pages.push(i)

  const handleChange = (e, page) => {
    e.preventDefault()
    if(page==props.currentPage) return;
    if(page < 1) page = 1;
    if(page > pageCount) page = pageCount;

    if(!props.onChange) {
      console.log('Pagination: no onChange function provided')
    } else {
      props.onChange(page)
    }
  }

  // console.log('total', props.total, 'pageCount', pageCount,'startPage',startPage,'endPage',endPage)

  return(
    <nav aria-label="Page navigation" className={props.className || ""}>
      <ul className="pagination">
        <li className={showPrev ? '' : 'disabled'}>
          <a
            href="#"
            aria-label="Previous"
            onClick={(e) => handleChange(e, props.currentPage - 1)}>
            <span aria-hidden="true">&laquo;</span>
          </a>
        </li>

        {startPage > 1 &&
          <li><a href="#" onClick={(e) => handleChange(e, 1)}>1</a></li>
        }

        { startPage > 2 &&
          <li>
            <a
              href="#"
              onClick={(e) => handleChange(e, props.currentPage - pageWindow) }
              >...</a>
          </li>
        }

        {pages.map((page) =>
          <li key={page} className={props.currentPage == page ? 'active' : ''}>
            <a href="#" onClick={(e) => handleChange(e, page)}>{page}</a>
          </li>
        )}

        {(endPage < (pageCount - 1)) &&
          <li>
            <a
              href="#"
              onClick={(e) => handleChange(e, props.currentPage + pageWindow) }
              >...</a>
          </li>
        }

        {(endPage < pageCount) &&
          <li>
            <a
              href="#"
              onClick={(e) => handleChange(e, pageCount)}>
              {pageCount}
            </a>
          </li>
        }

        <li className={showNext ? '' : 'disabled'}>
          <a
            href="#"
            aria-label="Next"
            onClick={(e) => handleChange(e, props.currentPage + 1)}>
            <span aria-hidden="true">&raquo;</span>
          </a>
        </li>
      </ul>
    </nav>

  )
}
