import React, { useEffect, useState, useRef, useMemo } from 'react';
import {DefeatableLink} from 'lib/components/defeatable_link';
import useL7Policy from '../../../lib/hooks/useL7Policy'
import useCommons from '../../../lib/hooks/useCommons'
import HelpPopover from '../shared/HelpPopover'
import L7PolicyListItem from './L7PolicyListItem'
import { Table } from 'react-bootstrap'
import { useGlobalState } from '../StateProvider'
import L7PolicySelected from './L7PolicySelected'
import queryString from 'query-string'
import ErrorPage from '../ErrorPage';
import { Tooltip, OverlayTrigger } from 'react-bootstrap';
import { addError } from 'lib/flashes';
import { SearchField } from 'lib/components/search_field';
import { policy } from "policy";
import { scope } from "ajax_helper";
import SmartLink from "../shared/SmartLink"

const L7PolicyList = ({props, loadbalancerID }) => {
  const {persistL7Policies, setSearchTerm, setSelected, reset, onSelectL7Policy} = useL7Policy()
  const {searchParamsToString} = useCommons()
  const [tableScroll, setTableScroll] = useState(false)
  const state = useGlobalState().l7policies
  const listenerID = useGlobalState().listeners.selected
  // timeout for scroll event
  let handleScrollTimeout = null
  // timeout for the event handler
  let eventHandlerTimeout = null
  const [count, setCount] = useState(0)

  useEffect(() => {    
    initialLoad()
    return () => {
      reset()
    }
  }, [listenerID]);

  const canCreate = useMemo(
    () => 
      policy.isAllowed("lbaas2:l7policy_create", {
        target: { scoped_domain_name: scope.domain }
      }),
    [scope.domain]
  );

  const initialLoad = () => {
    if (listenerID) {
      console.log("FETCH L7 POLICIES")
      persistL7Policies(loadbalancerID, listenerID, null).then((data) => {
        selectL7Policy(data)
      }).catch( error => {
      })
    }
  }

  const container = useRef(null)
  useEffect(() => {
    if (listenerID) {
      const containerElement = container.current 
      if(containerElement){
        // wait until the responsive table is build
        handleScrollListener(containerElement)
        return () => {      
          if (containerElement && containerElement.querySelector('.table-responsive')){
            containerElement.querySelector('.table-responsive').removeEventListener("scroll",handleScroll)
          }
          clearTimeout(handleScrollTimeout)
          clearTimeout(eventHandlerTimeout)
        } 
      }
    }
  },[listenerID])

  const handleScrollListener = (containerElement) => {
    if(eventHandlerTimeout) return
    setCount(count + 1)
    if ( containerElement && containerElement.querySelector('.table-responsive') ){
      containerElement.querySelector('.table-responsive').addEventListener('scroll', handleScroll);
    } else {
      if (count < 5) {
        eventHandlerTimeout = setTimeout(() => {
          eventHandlerTimeout = null
          handleScrollListener(containerElement)
        }, 500)
      }
    }
  }

  const handleScroll = () => {
    if(handleScrollTimeout) return
    setTableScroll(true)
    handleScrollTimeout = setTimeout(() => {
      handleScrollTimeout = null
      setTableScroll(false)
    }, 1000 )
  }

  const selectL7Policy = (data) => {
    const values = queryString.parse(props.location.search)    
    const id = values.l7policy
    if (id) {
      // check if id belows to the lb object
      const index = data.l7policies.findIndex((item) => item.id==id);
      if (index>=0) {
        // policy was selected
        setSelected(id)
        // filter the policy list to show just the one item
        setSearchTerm(id)
      } else {
        addError(<React.Fragment>L7 Policy <b>{id}</b> not found.</React.Fragment>)
      }
    } 
  }

  const restoreUrl = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectL7Policy(props)
  }

  const search = (term) => {
    if(hasNext && !isLoading) {
      persistL7Policies(loadbalancerID, listenerID, {limit: 9999}).catch( (error) => {
      })
    }
    setSearchTerm(term)
  }

  const error = state.error
  const hasNext = state.hasNext
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
      `${i.id} ${i.name} ${i.description} ${i.action}`.search(regex) >= 0
    )
    }
  }

  const l7Policies = filterItems(searchTerm, items)
  const isLoading = state.isLoading
  return useMemo(() => {
    console.log("RENDER L7 POLICIES")
    return ( 
      <React.Fragment>
        {listenerID &&
          <React.Fragment>
            { error ?
              <div className={selected ? "l7policies subtable multiple-subtable-left": "l7policies subtable"} ref={container}>
                <ErrorPage headTitle="L7 Policies" error={error} onReload={initialLoad}/>
              </div>
            :
              <div className={selected ? "l7policies subtable multiple-subtable-left": "l7policies subtable"} ref={container}>
                <div className="display-flex multiple-subtable-header">
                  <h4>L7 Policies</h4>
                  <HelpPopover text="Collection of L7 rules that get logically ANDed together as well as a routing policy for any given HTTP or terminated HTTPS client requests which match said rules. An L7 Policy is associated with exactly one HTTP or terminated HTTPS listener." />
                </div> 
                
                {selected && l7Policies.length == 1 ?
                  l7Policies.map( (l7Policy, index) =>
                    <div className="selected-l7policy" key={index}>
                      <L7PolicySelected props={props} listenerID={listenerID} l7Policy={l7Policy} onBackLink={restoreUrl}/>
                    </div>
                  )
                :
                  <React.Fragment>
                    <div className="toolbar searchToolbar">
                      <SearchField
                        value={searchTerm}
                        onChange={(term) => search(term)}
                        placeholder='name, ID, description or action' text='Searches by name, ID, description or action.'/> 
                      <div className="main-buttons">
                          <SmartLink
                            disabled={isLoading}
                            to={`/loadbalancers/${loadbalancerID}/listeners/${listenerID}/l7policies/new?${searchParamsToString(props)}`}
                            className='btn btn-primary btn-xs'
                            isAllowed={canCreate}
                            notAllowedText="Not allowed to create. Please check with your administrator.">
                            New L7 Policy
                          </SmartLink>
                        </div>
                    </div>

                    <Table className={l7Policies.length>0 ? "table table-hover policies" : "table policies"} responsive>
                      <thead>
                          <tr>
                              <th>Name/ID/Description</th>
                              <th>State</th>
                              <th>Prov. Status</th>
                              <th>Tags</th>
                              <th>
                                <div className="display-flex">
                                  Position
                                  <div className="margin-left">
                                  <OverlayTrigger placement="top" overlay={<Tooltip id="defalult-pool-tooltip">Sorted by Position ASC</Tooltip>}>
                                    <i className="fa fa-sort-asc" />
                                  </OverlayTrigger>  
                                  </div>
                                </div>
                              </th>
                              <th>Action/Redirect</th>
                              <th>#L7 Rules</th>
                              <th className='snug'></th>
                          </tr>
                      </thead>
                      <tbody>
                        {l7Policies && l7Policies.length>0 ?
                          l7Policies.map( (l7Policy, index) =>
                            <L7PolicyListItem 
                              props={props} 
                              l7Policy={l7Policy} 
                              searchTerm={searchTerm} 
                              key={index} 
                              tableScroll={tableScroll} 
                              listenerID={listenerID}
                              disabled={selected ? true : false}
                              />
                          )
                          :
                          <tr>
                            <td colSpan="9">
                              { isLoading ? <span className='spinner'/> : 'No L7 Policies found.' }
                            </td>
                          </tr>  
                        }
                      </tbody>
                    </Table>
                  </React.Fragment>
                }
              </div> 
            }          
          </React.Fragment>
        } 
      </React.Fragment>
    );
  } , [ listenerID, JSON.stringify(l7Policies), error, selected, isLoading, searchTerm, props, tableScroll])
}
 
export default L7PolicyList;