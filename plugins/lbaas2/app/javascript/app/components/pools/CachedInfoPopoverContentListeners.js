import React from 'react';
import { Link } from 'react-router-dom';

const CachedInfoPopoverContentListeners = ({listenerIDs, cachedListeners}) => {
  return (
    listenerIDs.length>0 ?
    listenerIDs.map( (id, index) =>
        <div key={id}>
          { cachedListeners[id] ?
            <React.Fragment>
              <div className="row">
                <div className="col-md-12">
                <Link to={`/listener/${id}/show`}>
                  {cachedListeners[id].name || id}
                </Link>
                </div>
              </div>
              {cachedListeners[id].name && 
                <div className="row">
                  <div className="col-md-12 text-nowrap">
                  <small className="info-text">{id}</small>
                  </div>                
                </div>
              }
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
          { index === listenerIDs.length - 1 ? "" : <hr/> }
        </div>
      )
    :
    <p>No Secrets Found</p>
  );
}
 
export default CachedInfoPopoverContentListeners;