import React from "react"
import { Link } from "react-router-dom"

const LbPopoverPoolContent = ({ lbID, poolIds, cachedPools }) => {
  return poolIds.length > 0 ? (
    poolIds.map((id, index) => (
      <div key={id}>
        {cachedPools[id] ? (
          <React.Fragment>
            <div className="row">
              <div className="col-md-12">
                <Link to={`/loadbalancers/${lbID}/show?pool=${id}`}>
                  {cachedPools[id].name || id}
                </Link>
              </div>
            </div>
            {cachedPools[id].name && (
              <div className="row">
                <div className="col-md-12 text-nowrap">
                  <small className="info-text">{id}</small>
                </div>
              </div>
            )}
            <div className="row">
              <div className="col-md-12">
                <b>Description:</b> {cachedPools[id].payload.description}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Algorithm:</b> {cachedPools[id].payload.lb_algorithm}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Protocol:</b> {cachedPools[id].payload.protocol}
              </div>
            </div>
          </React.Fragment>
        ) : (
          <div className="row">
            <div className="col-md-12 text-nowrap">
              <Link to={`/loadbalancers/${lbID}/show?pool=${id}`}>
                <small>{id}</small>
              </Link>
            </div>
          </div>
        )}
        {index === poolIds.length - 1 ? "" : <hr />}
      </div>
    ))
  ) : (
    <p>No pools found</p>
  )
}

export default LbPopoverPoolContent
