import React, { useEffect, useState } from 'react';
import {DefeatableLink} from 'lib/components/defeatable_link';
import HelpPopover from '../shared/HelpPopover'
import { useGlobalState } from '../StateProvider'
import { Table } from 'react-bootstrap'
import useCommons from '../../../lib/hooks/useCommons'
import useMember from '../../../lib/hooks/useMember'
import MemberListItem from './MemberListItem';
import ErrorPage from '../ErrorPage';
import { Tooltip, OverlayTrigger } from 'react-bootstrap';

const MemberList = ({props,loadbalancerID}) => {
  const poolID = useGlobalState().pools.selected
  const {searchParamsToString} = useCommons()
  const {persistMembers} = useMember()
  const state = useGlobalState().members

  useEffect(() => {    
    initialLoad()
  }, [poolID]);

  const initialLoad = () => {
    if (poolID) {
      console.log("FETCH MEMBERS")
      persistMembers(loadbalancerID, poolID).then((data) => {
      }).catch( error => {
      })
    }
  }

  const error = state.error
  const isLoading = state.isLoading
  const members = state.items

  console.log("RENDER member list")
  return (
    <React.Fragment>
      {poolID && 
        <React.Fragment>
          {error ?
            <div className="members subtalbe multiple-subtable-right">
              <ErrorPage headTitle="Members" error={error} onReload={initialLoad}/>
            </div>
          :
          <div className="members subtable multiple-subtable-right">
            <div className="display-flex">
              <h4>Members</h4>
              <HelpPopover text="Members are servers that serve traffic behind a load balancer. Each member is specified by the IP address and port that it uses to serve traffic." />
              <div className="btn-right">         
                <DefeatableLink
                  disabled={isLoading}
                  to={`/loadbalancers/${loadbalancerID}/pools/${poolID}/members/new?${searchParamsToString(props)}`}
                  className='btn btn-primary btn-xs'>
                  New Member
                </DefeatableLink>
            </div>
            </div>
            <Table className="table policies" responsive>
              <thead>
                  <tr>
                    <th>
                      <div className="display-flex">
                        Name
                        <div className="margin-left">
                        <OverlayTrigger placement="top" overlay={<Tooltip id="defalult-pool-tooltip">Sorted by Name ASC</Tooltip>}>
                          <i className="fa fa-sort-asc" />
                        </OverlayTrigger>  
                        </div>
                        /ID
                      </div>
                    </th>
                    <th>IP Address</th>
                    <th>State/Prov. Status</th>
                    <th>Tags</th>
                    <th style={{width:"10%"}}>Protocol Port</th>
                    <th style={{width:"10%"}}>Weight</th>
                    <th className='snug'></th>
                  </tr>
              </thead>
              <tbody>
                {members && members.length>0 ?
                  members.map( (member, index) =>
                    <MemberListItem loadbalancerID={loadbalancerID} poolID={poolID} member={member} key={index}/>
                  )
                :
                  <tr>
                    <td colSpan="7">
                      { isLoading ? <span className='spinner'/> : 'No Members found.' }
                    </td>
                  </tr>
                }
              </tbody>
          </Table>
          </div>
        }
        </React.Fragment>
      }
    </React.Fragment>
   );
}
 
export default MemberList;