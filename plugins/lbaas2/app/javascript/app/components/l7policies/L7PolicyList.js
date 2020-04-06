import React, { useEffect, useState, useRef } from 'react';
import {DefeatableLink} from 'lib/components/defeatable_link';
import useL7Policy from '../../../lib/hooks/useL7Policy'
import useCommons from '../../../lib/hooks/useCommons'
import HelpPopover from '../shared/HelpPopover'
import L7PolicyListItem from './L7PolicyListItem'
import { Table } from 'react-bootstrap'

const Policies = ({props, loadbalancerID, listener}) => {
  const {fetchL7Policies} = useL7Policy()
  const {searchParamsToString} = useCommons()
  const [isLoading, setIsLoading] = useState(false)
  const [selected, setSelected] = useState(null)
  const [searchTerm, setSearchTerm] = useState(null)
  const [tableScroll, setTableScroll] = useState(false)
  const [state, setState] = useState({
    items: [],
    receivedAt: null,
    hasNext: false,
    marker: null,
    error: null
  })
  let timeout = null

  useEffect(() => {
    console.log("FETCH L7 POLICIES")
    setIsLoading(true)
    fetchL7Policies(loadbalancerID, listener.id, null).then((data) => {
      setIsLoading(false)
      updateState(data)
    }).catch( error => {
      setIsLoading(false)
      // TODO show error
    })
  }, [listener.id, listener.l7policies]);

  const container = useRef(null)
  useEffect(() => {
    const containerElement = container.current 
    containerElement.querySelector('.table-responsive').addEventListener('scroll', handleScroll);
    return () => {
      containerElement.querySelector('.table-responsive').removeEventListener("scroll",handleScroll)
      clearTimeout(timeout)
    }
  },[])

  const updateState = (data) => {
    let newItems = (state.items.slice() || []).concat(data.l7policies);
    // filter duplicated items
    newItems = newItems.filter( (item, pos, arr) => arr.findIndex(i => i.id == item.id)==pos );
    // create marker before sorting just in case there is any difference
    const marker = data.l7policies[data.l7policies.length-1]
    // sort by position
    const test = newItems.sort((a, b) => a.position - b.position)
    console.group("SORT BY POSITION")
    console.log(test)
    console.groupEnd()
    // newItems = newItems.sort((a, b) => a.position < b.position)
    setState({...state,
      items: newItems, 
      error: null,
      hasNext: data.has_next,
      marker: marker,
      updatedAt: Date.now()})
  }

  const selectL7Policy = () => {
    const values = queryString.parse(props.location.search)
    const id = values.l7policy

    if (id) {
      // policy was selected
      setSelected(id)
      // filter the policy list to show just the one item
      setSearchTerm(id)
    } else {
      // NOT FOUND
    }
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
      `${i.id} ${i.name} ${i.description}`.search(regex) >= 0
    )
    }
  }

  console.log("RENDER L7 POLICIES")
  const l7Policies =  filterItems(searchTerm, items)
  return ( 
    <div className="highlight" ref={container}>
      <div className="display-flex">
        <h5>L7 Policies</h5>
        <HelpPopover text="Collection of L7 rules that get logically ANDed together as well as a routing policy for any given HTTP or terminated HTTPS client requests which match said rules. An L7 Policy is associated with exactly one HTTP or terminated HTTPS listener." />
        {!selected &&
            <DefeatableLink
              disabled={isLoading}
              to={`/loadbalancers/${loadbalancerID}/l7policies/new?${searchParamsToString(props)}`}
              className='btn btn-link btn-right'>
              New L7 Policy
            </DefeatableLink>
          }
      </div> 

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
              <L7PolicyListItem l7Policy={l7Policy} searchTerm={searchTerm} key={index} tableScroll={tableScroll}/>
            )
            :
            <tr>
              <td colSpan="9">
                { isLoading ? <span className='spinner'/> : 'No L7 policies found.' }
              </td>
            </tr>  
          }
        </tbody>
      {/* </table> */}
      </Table>
    </div>    
   );
}
 
export default Policies;