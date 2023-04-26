import React, { useState } from "react"
import { Link } from "react-router-dom"
import useL7Policy from "../../lib/hooks/useL7Policy"
import CopyPastePopover from "../shared/CopyPastePopover"
import useListener from "../../lib/hooks/useListener"
import { actionRedirect } from "../../helpers/l7PolicyHelpers"

const CachedInfoPopoverContent = ({
  props,
  lbID,
  listenerID,
  l7PolicyIDs,
  cachedl7PolicyIDs,
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
    onSelectPolicyWithListner(props, listenerID, id)
  }

  const onSelectPolicyWithListner = (props, listenerID, l7PolicyID) => {
    const pathname = props.location.pathname
    const searchParams = new URLSearchParams(props.location.search)
    searchParams.set("listener", listenerID)
    searchParams.set("l7policy", l7PolicyID)
    props.history.push({
      pathname: pathname,
      search: searchParams.toString(),
    })
    // Listener was selected
    listenerSetSelected(listenerID)
    // filter the listener list to show just the one item
    listenerSetSearchTerm(listenerID)
    // L7Policy was selected
    l7policySetSelected(l7PolicyID)
    // filter list in case we still show the list
    l7policySetSearchTerm(l7PolicyID)
  }

  return l7PolicyIDs.length > 0 ? (
    l7PolicyIDs.map((id, index) => (
      <div key={id}>
        {cachedl7PolicyIDs[id] ? (
          <>
            <div className="row">
              <div className="col-md-12">
                <Link onClick={(e) => onClick(e, id)} to="#">
                  {cachedl7PolicyIDs[id].name || id}
                </Link>
              </div>
            </div>
            {cachedl7PolicyIDs[id].name && (
              <div className="row">
                <div className="col-md-12 text-nowrap">
                  <small className="info-text">{id}</small>
                </div>
              </div>
            )}
            <div className="row">
              <div className="col-md-12">
                <b>Description:</b> {cachedl7PolicyIDs[id].payload.description}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Position:</b> {cachedl7PolicyIDs[id].payload.position}
              </div>
            </div>
            <div className="row">
              <div className="col-md-12">
                <b>Action/Redirect:</b>
                <br />
                {cachedl7PolicyIDs[id].payload.action}
                {actionRedirect(cachedl7PolicyIDs[id].payload.action).map(
                  (redirect, index) => (
                    <span className="display-flex" key={index}>
                      <br />
                      <span>{redirect.label}: </span>
                      {redirect.value === "redirect_prefix" ||
                      redirect.value === "redirect_url" ? (
                        <CopyPastePopover
                          text={cachedl7PolicyIDs[id].payload[redirect.value]}
                          size={20}
                          shouldPopover={false}
                          shouldCopy={false}
                          bsClass="cp label-right"
                        />
                      ) : (
                        <span className="label-right">
                          {cachedl7PolicyIDs[id].payload[redirect.value]}
                        </span>
                      )}
                    </span>
                  )
                )}
              </div>
            </div>
          </>
        ) : (
          <div className="row">
            <div className="col-md-12 text-nowrap">
              <Link onClick={(e) => onClick(e, id)} to="#">
                <small>{id}</small>
              </Link>
            </div>
          </div>
        )}
        {index === l7PolicyIDs.length - 1 ? "" : <hr />}
      </div>
    ))
  ) : (
    <p>No L7 Policies found</p>
  )
}

export default CachedInfoPopoverContent
