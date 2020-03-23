import React, { useEffect, useState } from 'react';
import {DefeatableLink} from 'lib/components/defeatable_link';
import useL7Policy from '../../../lib/hooks/useL7Policy'
import useCommons from '../../../lib/hooks/useCommons'

const Policies = ({props, loadbalancerID, listenerID}) => {
  const {fetchL7Policies} = useL7Policy()
  const {searchParamsToString} = useCommons()
  const [isLoading, setIsLoading] = useState(false)
  const [selected, setSelected] = useState(null)
  const [searchTerm, setSearchTerm] = useState(null)
  const [state, setState] = useState({
    items: [],
    receivedAt: null,
    hasNext: false,
    marker: null,
    error: null
  })

  useEffect(() => {  
    setIsLoading(true)

    console.group("LISTENER_ID")
    console.log(listenerID)
    console.groupEnd()

    fetchL7Policies(loadbalancerID, listenerID, state.marker).then((data) => {
      setIsLoading(false)
      updateState(data)
      // selectListener()
    }).catch( error => {
      setIsLoading(false)
      // TODO
    })
  }, [listenerID]);

  const selectL7Policy = () => {
    const values = queryString.parse(props.location.search)
    const id = values.l7policy

    if (id) {
      // Listener was selected
      setSelected(id)
      // filter the listener list to show just the one item
      setSearchTerm(id)
    } else {
      // NOT FOUND
    }
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

  const l7Policies =  filterItems(searchTerm, items)
  return ( 
    <div className="highlight">
      <h5>L7 Policies</h5>
      <p>Collection of L7 rules that get logically ANDed together as well as a routing policy for any given HTTP or terminated HTTPS client requests which match said rules. An L7 Policy is associated with exactly one HTTP or terminated HTTPS listener.</p>

      <div className='toolbar'>
        <div className="main-buttons">
          <DefeatableLink
            disabled={selected || isLoading}
            to={`/loadbalancers/${loadbalancerID}/l7policies/new?${searchParamsToString(props)}`}
            className='btn btn-primary'>
            New
          </DefeatableLink>
        </div>
      </div>  

      <table className={l7Policies.length>0 ? "table table-hover policies" : "table policies"}>
        <thead>
            <tr>
                <th>Name/ID</th>
                <th>Description</th>
                <th>State</th>
                <th>Prov. Status</th>
                <th>Position</th>
                <th>Action</th>
                <th>Redirect To</th>
                <th>#Rules</th>
                <th className='snug'></th>
            </tr>
        </thead>
        <tbody>
          <tr>
            <td colSpan="8">
              { isLoading ? <span className='spinner'/> : 'No L7 policies found.' }
            </td>
          </tr>  
        </tbody>
      </table>
    </div>    
   );
}
 
export default Policies;