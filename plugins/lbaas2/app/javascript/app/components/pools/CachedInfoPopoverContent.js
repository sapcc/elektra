import React from 'react';
import { Link } from 'react-router-dom';

const CachedInfoPopoverContent = ({memberIDs, cachedMembers}) => {
  return (
    memberIDs.length>0 ?
      memberIDs.map( (id, index) =>
        <div key={id}>
          { cachedMembers[id] ?
            <React.Fragment>
              <div className="row">
                <div className="col-md-12">
                <Link to={`/listener/${id}/show`}>
                  {cachedMembers[id].name || id}
                </Link>
                </div>
              </div>
              {cachedMembers[id].name && 
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
          { index === memberIDs.length - 1 ? "" : <hr/> }
        </div>
      )
    :
    <p>No Members found</p>
  );
}
 
export default CachedInfoPopoverContent;