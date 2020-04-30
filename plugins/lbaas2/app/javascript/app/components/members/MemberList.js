import React, { useEffect, useState, useRef } from 'react';
import {DefeatableLink} from 'lib/components/defeatable_link';
import HelpPopover from '../shared/HelpPopover'
import { useGlobalState } from '../StateProvider'
import { Table } from 'react-bootstrap'
import useCommons from '../../../lib/hooks/useCommons'

const MemberList = (props) => {
  const poolID = useGlobalState().pools.selected
  const [selected, setSelected] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const {searchParamsToString} = useCommons()

  return (
    <React.Fragment>
      {poolID && 

          <div className="members subtable multiple-subtable-right">
            <div className="display-flex">
              <h4>Members</h4>
              <HelpPopover text="Members are servers that serve traffic behind a load balancer. Each member is specified by the IP address and port that it uses to serve traffic." />
              <div className="btn-right">
                {!selected &&              
                    <DefeatableLink
                      disabled={isLoading}
                      to={`/loadbalancers/test`}
                      className='btn btn-primary btn-xs'>
                      New L7 Policy
                    </DefeatableLink>
                  }
            </div>
            </div>
            <Table className="table policies" responsive>
              <thead>
                  <tr>
                      <th>IP Address</th>
                      <th>State</th>
                      <th>Prov. Status</th>
                      <th>Protocol Port</th>
                      <th>Weight</th>
                      <th>Tags</th>
                      <th className='snug'></th>
                  </tr>
              </thead>
              <tbody>
                <td colSpan="9">
                  No Members found.
                </td>
              </tbody>
          </Table>
          </div>
      }
    </React.Fragment>
   );
}
 
export default MemberList;