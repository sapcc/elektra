import React from "react"

const Pagination = ({ isLoading, items, hasNext, handleClick }) => {
  return (
    <div className="pagination">
      {isLoading ? (
        <React.Fragment>
          <span>{items.length} Items</span>
          <span> | </span>
          <span className="main-buttons">
            <span className="spinner"></span> Loading more items...
          </span>
        </React.Fragment>
      ) : (
        <React.Fragment>
          <span>{items.length} Items</span>
          {hasNext && (
            <React.Fragment>
              <span> | </span>
              <button
                onClick={(e) => handleClick(e, "next")}
                className="btn btn-link"
                style={{ paddingLeft: 0, paddingRight: 0 }}
              >
                Load Next
              </button>
              <span> | </span>
              <button
                onClick={(e) => handleClick(e, "all")}
                className="btn btn-link"
                style={{ paddingLeft: 0, paddingRight: 0 }}
              >
                All
              </button>
            </React.Fragment>
          )}
        </React.Fragment>
      )}
    </div>
  )
}

export default Pagination
