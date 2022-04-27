import React from "react"
import { Link } from "react-router-dom"
import useListener from "../../lib/hooks/useListener"
import useL7Policy from "../../lib/hooks/useL7Policy"

const CachedInfoPopoverContentListeners = ({
  props,
  loadbalancerID,
  listenerIDs,
  cachedListeners,
}) => {
  const listenerSetSelected = useListener().setSelected
  const listenerSetSearchTerm = useListener().setSearchTerm
  const l7policySetSelected = useL7Policy().setSelected
  const l7policySetSearchTerm = useL7Policy().setSearchTerm

  const onClick = (e, id) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectListner(props, id)
  }

  const onSelectListner = (props, id) => {
    const pathname = props.location.pathname
    const searchParams = new URLSearchParams(props.location.search)
    searchParams.set("listener", id)
    searchParams.set("l7policy", "")
    props.history.push({
      pathname: pathname,
      search: searchParams.toString(),
    })
    // Listener was selected
    listenerSetSelected(id)
    // filter the listener list to show just the one item
    listenerSetSearchTerm(id)
    // deselect L7Policy
    l7policySetSelected(null)
    // filter list in case we still show the list
    l7policySetSearchTerm(null)
  }

  return listenerIDs.length > 0 ? (
    listenerIDs.map((id, index) => (
      <div key={id}>
        {cachedListeners[id] ? (
          <React.Fragment>
            <div className="row">
              <div className="col-md-12">
                <Link onClick={(e) => onClick(e, id)} to="#">
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
        {index === listenerIDs.length - 1 ? "" : <hr />}
      </div>
    ))
  ) : (
    <p>No Secrets Found</p>
  )
}

export default CachedInfoPopoverContentListeners
