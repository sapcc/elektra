import React from "react"
import { Link } from "react-router-dom"

const LbPopoverListenerContent = ({ lbID, listenerIds, cachedListeners }) => {
  console.log("RENDER lbPoopover CONTENT")
  return listenerIds.length > 0 ? (
    listenerIds.map((id, index) => (
      <div key={id}>
        {cachedListeners[id] ? (
          <React.Fragment>
            <div className="row">
              <div className="col-md-12">
                <Link to={`/loadbalancers/${lbID}/show?listener=${id}`}>
                  {cachedListeners[id].name || id}
                </Link>
              </div>
            </div>
            {cachedListeners[id].name && (
              <div className="row">
                <div className="col-md-12 text-nowrap">
                  <small className="info-text">{id}</small>
                </div>
              </div>
            )}
            <div className="row">
              <div className="col-md-12">
                <b>Description:</b> {cachedListeners[id].payload.description}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Protocol:</b> {cachedListeners[id].payload.protocol}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Protocol Port:</b>{" "}
                {cachedListeners[id].payload.protocol_port}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Default Pool:</b>{" "}
                {cachedListeners[id].payload.default_pool_id ? (
                  <i className="fa fa-check" />
                ) : (
                  <i className="fa fa-times" />
                )}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Connection Limit:</b>{" "}
                {cachedListeners[id].payload.connection_limit}
              </div>
            </div>
          </React.Fragment>
        ) : (
          <div className="row">
            <div className="col-md-12 text-nowrap">
              <Link to={`/listeners/${id}/show`}>
                <small>{id}</small>
              </Link>
            </div>
          </div>
        )}
        {index === listenerIds.length - 1 ? "" : <hr />}
      </div>
    ))
  ) : (
    <p>No listeners found</p>
  )
}

export default LbPopoverListenerContent
