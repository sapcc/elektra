export default ({
  isFetching,
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
        <div><span className="spinner"></span> Loading...</div>
        :
        <div>
          { loadNextButton &&
            <button
              className={loadNextItemsCssClass}
              onClick={(e) => alert('load Next')}>
              {loadNextLabel}
            </button>
          }
          { loadAllButton &&
            <button
              className={loadAllItemsCssClass}
              onClick={(e) => alert('load All')}>
              {loadAllLabel}
            </button>
          }
        </div>
      }
    </div>
  )
}
