import React from "react"
import { Link } from "react-router-dom"
import usePool from "../../lib/hooks/usePool"

const CachedInfoPopoverContent = ({
  props,
  lbID,
  poolID,
  memberIDs,
  cachedMembers,
}) => {
  const { onSelectPool } = usePool()

  const onClick = (e, id) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectPool(props, poolID)
  }

  return memberIDs.length > 0 ? (
    memberIDs.map((id, index) => (
      <div key={id}>
        {cachedMembers[id] ? (
          <React.Fragment>
            <div className="row">
              <div className="col-md-12">
                <Link onClick={(e) => onClick(e, id)} to="#">
                  {cachedMembers[id].name || id}
                </Link>
              </div>
            </div>
            {cachedMembers[id].name && (
              <div className="row">
                <div className="col-md-12 text-nowrap">
                  <small className="info-text">{id}</small>
                </div>
              </div>
            )}
            <div className="row">
              <div className="col-md-12">
                <b>IP Address:</b> {cachedMembers[id].payload.address}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Protocol Port:</b> {cachedMembers[id].payload.protocol_port}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Weight:</b> {cachedMembers[id].payload.weight}
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
        {index === memberIDs.length - 1 ? "" : <hr />}
      </div>
    ))
  ) : (
    <p>No Members found</p>
  )
}

export default CachedInfoPopoverContent
