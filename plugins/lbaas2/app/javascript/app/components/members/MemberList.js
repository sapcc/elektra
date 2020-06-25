import React, { useEffect, useState, useMemo } from 'react';
import {DefeatableLink} from 'lib/components/defeatable_link';
import HelpPopover from '../shared/HelpPopover'
import { useGlobalState } from '../StateProvider'
import { Table } from 'react-bootstrap'
import useCommons from '../../../lib/hooks/useCommons'
import useMember from '../../../lib/hooks/useMember'
import MemberListItem from './MemberListItem';
import ErrorPage from '../ErrorPage';
import { Tooltip, OverlayTrigger } from 'react-bootstrap';
import { SearchField } from 'lib/components/search_field';
import { policy } from "policy";
import { scope } from "ajax_helper";
import SmartLink from "../shared/SmartLink"

const MemberList = ({props,loadbalancerID}) => {
  const poolID = useGlobalState().pools.selected
  const {searchParamsToString} = useCommons()
  const {persistMembers, setSearchTerm} = useMember()
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

  const canCreate = useMemo(
    () => 
      policy.isAllowed("lbaas2:member_create", {
        target: { scoped_domain_name: scope.domain }
      }),
    [scope.domain]
  );

  const search = (term) => {
    setSearchTerm(term)
  }

  const error = state.error
  const isLoading = state.isLoading
  const searchTerm = state.searchTerm
  const selected = state.selected
  const items = state.items

  const filterItems = (searchTerm, items) => {
    if(!searchTerm) return items;
    // filter items      
    if (selected) {
      return items.filter((i) =>
        i.id == searchTerm.trim()
      )
    } else {
      const regex = new RegExp(searchTerm.trim(), "i");
      return items.filter((i) =>
      `${i.id} ${i.name} ${i.address} ${i.protocol_port}`.search(regex) >= 0
    )
    }
  }

  const members = filterItems(searchTerm, items)
  return useMemo(() => {
    console.log("RENDER member list")
    return (
      <React.Fragment>
        {poolID && 
          <React.Fragment>
            {error ?
              <div className="members subtable multiple-subtable-right">
                <ErrorPage headTitle="Members" error={error} onReload={initialLoad}/>
              </div>
            :
            <div className="members subtable multiple-subtable-right">
              <div className="display-flex multiple-subtable-header">
                <h4>Members</h4>
                <HelpPopover text="Members are servers that serve traffic behind a load balancer. Each member is specified by the IP address and port that it uses to serve traffic." />
              </div>

              <React.Fragment>
                <div className="toolbar searchToolbar">
                  <SearchField
                    value={searchTerm}
                    onChange={(term) => search(term)}
                    placeholder='Name, ID, IP or port' text='Searches by Name, ID, IP address or protocol port.'/> 
                  
                  <div className="main-buttons">
                    <SmartLink
                      disabled={isLoading}
                      to={`/loadbalancers/${loadbalancerID}/pools/${poolID}/members/new?${searchParamsToString(props)}`}
                      className='btn btn-primary btn-xs'
                      isAllowed={canCreate}
                      notAllowedText="Not allowed to create. Please check with your administrator.">
                      New Member
                    </SmartLink>
                  </div>
                </div>
              </React.Fragment>

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
                      <MemberListItem 
                        props={props} 
                        poolID={poolID} 
                        member={member} 
                        key={index}
                        searchTerm={searchTerm}
                        />
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
  } , [poolID, JSON.stringify(members), error, isLoading, searchTerm, props])
}
 
export default MemberList;