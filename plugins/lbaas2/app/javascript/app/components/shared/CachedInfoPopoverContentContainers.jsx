import React from 'react';

const CachedInfoPopoverContentContainers = ({containers}) => {
  return (
    containers.length>0 ?
     containers.map( (container, index) =>
        <div key={container} key={index}>
          <div className="row">
            <div className="col-md-12">
              {container.ref &&
                <React.Fragment>
                  <div>{container.name}:</div>
                  <div className="word-break">
                    <a href={container.ref} target="_blank">
                      {container.ref}
                    </a>
                  </div>
                </React.Fragment>
              }
              {container.refList &&
                <React.Fragment>
                  <div>{container.name}:</div>
                  <div className="list">
                  {container.refList.map( (item, refListIndex) =>  
                    <div className="list-entry word-break" key={refListIndex}> 
                      <a  href={item} target="_blank">
                        {item}
                      </a>                    
                    </div>
                  )}
                  </div>
                </React.Fragment>
              }
            </div>
          </div>
          { index === containers.length - 1 ? "" : <hr/> }
        </div>
      )
    :
    <p>No Containers Found</p>
  );
}
 
export default CachedInfoPopoverContentContainers;