import React, { useEffect, useState, useRef } from 'react';
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

const L7PolicyList = ({props, loadbalancerID }) => {
  const {persistL7Policies, setSearchTerm, setSelected, reset} = useL7Policy()
  const {searchParamsToString} = useCommons()
  const [tableScroll, setTableScroll] = useState(false)
  const state = useGlobalState().l7policies
  const listenerID = useGlobalState().listeners.selected
  let timeout = null

  useEffect(() => {    
    initialLoad()
    return () => {
      reset()
    }
  }, [listenerID]);

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
        containerElement.querySelector('.table-responsive').addEventListener('scroll', handleScroll);
        return () => {      
          if (containerElement && containerElement.querySelector('.table-responsive')){
            containerElement.querySelector('.table-responsive').removeEventListener("scroll",handleScroll)
          }
          clearTimeout(timeout)
        } 
      }
    }
  },[listenerID])

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
      }
    } else {
      // NOT FOUND
    }
  }

  const restoreUrl = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectL7Policy()
  }

  const handleScroll = () => {
    if(timeout) return
    setTableScroll(true)
    timeout = setTimeout(() => {
      timeout = null
      setTableScroll(false)
    }, 1000 )
  }

  const error = state.error
  const hasNext = state.hasNext
  const searchTerm = state.searchTerm
  const selected = state.selected
  const items = state.items

  const onSelectL7Policy = (l7PolicyID) => {  
    const id = l7PolicyID || ""
    const pathname = props.location.pathname; 
    const searchParams = new URLSearchParams(props.location.search); 
    searchParams.set("l7policy", id);
    props.history.push({
      pathname: pathname,
      search: searchParams.toString()
    })

    // L7Policy was selected
    setSelected(l7PolicyID)
    // filter list in case we still show the list
    setSearchTerm(l7PolicyID)    
  }

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
      `${i.id} ${i.name} ${i.description}`.search(regex) >= 0
    )
    }
  }

  console.log("RENDER L7 POLICIES")
  const l7Policies = filterItems(searchTerm, items)
  const isLoading = state.isLoading
  return ( 
    <React.Fragment>
      {listenerID &&
        <React.Fragment>
          { error ?
            <div className={selected ? "l7policies subtable multiple-subtable-left": "l7policies subtable"} ref={container}>
              <ErrorPage headTitle="L7 Policy" error={error} onReload={initialLoad}/>
            </div>
          :
            <div className={selected ? "l7policies subtable multiple-subtable-left": "l7policies subtable"} ref={container}>
              <div className="display-flex multiple-subtable-padding-container">
                <h4>L7 Policies</h4>
                <HelpPopover text="Collection of L7 rules that get logically ANDed together as well as a routing policy for any given HTTP or terminated HTTPS client requests which match said rules. An L7 Policy is associated with exactly one HTTP or terminated HTTPS listener." />
                <div className="btn-right">
                  {!selected &&              
                      <DefeatableLink
                        disabled={isLoading}
                        to={`/loadbalancers/${loadbalancerID}/l7policies/new?${searchParamsToString(props)}`}
                        className='btn btn-primary btn-xs'>
                        New L7 Policy
                      </DefeatableLink>
                    }
                </div>
              </div> 
              
              {selected && l7Policies.length == 1 ?
                l7Policies.map( (l7Policy, index) =>
                  <div className="selected-l7policy" key={index}>
                    <L7PolicySelected l7Policy={l7Policy} onBackLink={restoreUrl}/>
                  </div>
                )
              :
                <Table className={l7Policies.length>0 ? "table table-hover policies" : "table policies"} responsive>
                  <thead>
                      <tr>
                          <th>Name/ID</th>
                          <th>Description</th>
                          <th>State</th>
                          <th>Prov. Status</th>
                          <th>Tags</th>
                          <th>Position</th>
                          <th>Action/Redirect</th>
                          <th>#Rules</th>
                          <th className='snug'></th>
                      </tr>
                  </thead>
                  <tbody>
                    {l7Policies && l7Policies.length>0 ?
                      l7Policies.map( (l7Policy, index) =>
                        <L7PolicyListItem l7Policy={l7Policy} searchTerm={searchTerm} key={index} tableScroll={tableScroll} onSelected={onSelectL7Policy}/>
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
              }
            </div> 
          }          
        </React.Fragment>
      } 
    </React.Fragment>
  );
}
 
export default L7PolicyList;