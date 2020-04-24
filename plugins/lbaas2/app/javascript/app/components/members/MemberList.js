import React from 'react';
import HelpPopover from '../shared/HelpPopover'
import { useGlobalState } from '../StateProvider'

const MemberList = () => {
  const poolID = useGlobalState().pools.selected

  return (
    <React.Fragment>
      {poolID && 
        <div className="subtable">
          <div className="display-flex">
            <h5>Members</h5>
            <HelpPopover text="Members are servers that serve traffic behind a load balancer. Each member is specified by the IP address and port that it uses to serve traffic." />
          </div>
        </div>
      }
    </React.Fragment>
   );
}
 
export default MemberList;