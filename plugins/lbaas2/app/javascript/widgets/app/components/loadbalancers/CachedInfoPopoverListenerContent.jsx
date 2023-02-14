import React from "react"
import { Link } from "react-router-dom"
import Log from "../shared/logger"
import BooleanLabel from "../shared/BooleanLabel"

const LbPopoverListenerContent = ({ lbID, listenerIds, cachedListeners }) => {
  Log.debug("RENDER lbPoopover CONTENT")
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
                <BooleanLabel
                  value={cachedListeners[id].payload.default_pool_id}
                />
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
              <Link to={`/loadbalancers/${lbID}/show?listener=${id}`}>
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
