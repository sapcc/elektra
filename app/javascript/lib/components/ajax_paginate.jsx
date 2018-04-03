export default ({
  hasNext,
  isFetching,
  onLoadNext,
  onLoadAll,
  loadNextButton=true,
  loadAllButton=false,
  loadNextLabel='Load Next',
  loadAllLabel='Load All',
  loadNextItemsCssClass='btn btn-primary btn-sm',
  loadAllItemsCssClass='btn btn-default btn-sm'
}) => {
  return (
    <div className='ajax-paginate'>
      { isFetching ?
        <div className='buttons'><span className="spinner"></span> Loading...</div>
        :
        ( hasNext &&
          <div className='buttons'>
            { loadNextButton &&
              <button
                className={loadNextItemsCssClass}
                onClick={(e) => onLoadNext()}>
                {loadNextLabel}
              </button>
            }
            { loadAllButton &&
              <button
                className={loadAllItemsCssClass}
                onClick={(e) => onLoadAll()}>
                {loadAllLabel}
              </button>
            }
          </div>
        )
      }
    </div>
  )
}
