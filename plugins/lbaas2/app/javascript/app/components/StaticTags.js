import React from 'react';

const StaticTags = ({tags}) => {
  console.log("render tags")
  return ( 
    <React.Fragment>
      <div className="static-tags clearfix">
        {tags.map( (tag, index) =>
        <div key={index} className="tag">
          <div className="value">
            {tag}
          </div>
        </div>
      )}
      </div>
    </React.Fragment>
   );
}
 
export default StaticTags;