import React from 'react';
import { Link } from 'react-router-dom';
import useL7Policy from '../../../lib/hooks/useL7Policy'
import CopyPastePopover from '../shared/CopyPastePopover'

const CachedInfoPopoverContent = ({l7PolicyIDs, cachedl7PolicyIDs}) => {
  const {actionRedirect} = useL7Policy()
  return (
    l7PolicyIDs.length>0 ?
    l7PolicyIDs.map( (id, index) =>
    <div key={id}>
      { cachedl7PolicyIDs[id] ?
        <React.Fragment>
          <div className="row">
            <div className="col-md-12">
            <Link to={`/listener/${id}/show`}>
              {cachedl7PolicyIDs[id].name || id}
            </Link>
            </div>
          </div>
          {cachedl7PolicyIDs[id].name && 
            <div className="row">
              <div className="col-md-12 text-nowrap">
              <small className="info-text">{id}</small>
              </div>                
            </div>
          }
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
              <b>Action/Redirect:</b><br/>
              {cachedl7PolicyIDs[id].payload.action}
              {actionRedirect(cachedl7PolicyIDs[id].payload.action).map( (redirect, index) =>
                <span className="display-flex" key={index}>
                  <br/><span>{redirect.label}: </span>
                  {redirect.value === "redirect_prefix" || redirect.value === "redirect_url" ?
                    <CopyPastePopover text={cachedl7PolicyIDs[id].payload[redirect.value]} size={20} shouldPopover={false} shouldCopy={false} bsClass="cp label-right"/>
                  :
                  <span className="label-right">{cachedl7PolicyIDs[id].payload[redirect.value]}</span>              
                  }
                </span>
              )}
            </div>
          </div>
        </React.Fragment>
        :
        <div className="row">
          <div className="col-md-12 text-nowrap">
            <Link to={`/listeners/${id}/show`}>
              <small>{id}</small>
            </Link> 
          </div>                
        </div> 
      }
      { index === l7PolicyIDs.length - 1 ? "" : <hr/> }
    </div>
    )
  :
  <p>No L7 Policies found</p>
 );
}
 
export default CachedInfoPopoverContent;