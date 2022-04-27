import React from "react"
import { Link } from "react-router-dom"
import CopyPastePopover from "../shared/CopyPastePopover"
import useL7Policy from "../../lib/hooks/useL7Policy"
import BooleanLabel from "../shared/BooleanLabel"

const CachedInfoPopoverContent = ({
  props,
  lbID,
  listenerID,
  l7PolicyID,
  l7RuleIDs,
  cachedl7RuleIDs,
}) => {
  const { onSelectL7Policy } = useL7Policy()

  const onClick = (e, id) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectL7Policy(props, l7PolicyID)
  }

  return l7RuleIDs.length > 0 ? (
    l7RuleIDs.map((id, index) => (
      <div key={id}>
        {cachedl7RuleIDs[id] ? (
          <React.Fragment>
            <div className="row">
              <div className="col-md-12">
                <Link onClick={(e) => onClick(e, id)} to="#">
                  {id}
                </Link>
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Type/Compare Type:</b>
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                {cachedl7RuleIDs[id].payload.type}
                <br />
                {cachedl7RuleIDs[id].payload.compare_type}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Invert:</b>{" "}
                <BooleanLabel value={cachedl7RuleIDs[id].payload.invert} />
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Key:</b> {cachedl7RuleIDs[id].payload.key}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <span className="display-flex">
                  <b>Value: </b>
                  <CopyPastePopover
                    text={cachedl7RuleIDs[id].payload.value}
                    size={20}
                    shouldPopover={false}
                    shouldCopy={false}
                    bsClass="cp label-right"
                  />
                </span>
              </div>
            </div>
          </React.Fragment>
        ) : (
          <div className="row">
            <div className="col-md-12 text-nowrap">
              <Link onClick={(e) => onClick(e, id)} to="#">
                <small>{id}</small>
              </Link>
            </div>
          </div>
        )}
        {index === l7RuleIDs.length - 1 ? "" : <hr />}
      </div>
    ))
  ) : (
    <p>No L7 Rules found</p>
  )
}

export default CachedInfoPopoverContent
