import React from 'react';
import { useEffect, useState } from 'react'
import useListener from '../../../lib/hooks/useListener'
import {DefeatableLink} from 'lib/components/defeatable_link';
import ListenerItem from './ListenerItem'
import queryString from 'query-string'
import { Link } from 'react-router-dom';
import Policies from './Policies'

const ListenerList = ({props, loadbalancerID}) => {
  const {fetchListeners} = useListener()
  const [searchTerm, setSearchTerm] = useState(null)
  const [selected, setSelected] = useState(null)
  const [isLoading, setIsLoading]= useState(false)
  const [state, setState] = useState({
    items: [],
    receivedAt: null,
    hasNext: false,
    marker: null,
    error: null
  })

  useEffect(() => {  
    setIsLoading(true)
    fetchListeners(loadbalancerID, state.marker).then((data) => {
      setIsLoading(false)
      updateState(data)
      selectListener()
    }).catch( error => {
      // TODO
    })
  }, [loadbalancerID]);

  const selectListener = () => {
    const values = queryString.parse(props.location.search)
    const id = values.listener

    if (id) {
      // Listener was selected
      setSelected(id)
      // filter the listener list to show just the one item
      setSearchTerm(id)
    } else {
      // NOT FOUND
    }
  }

  const onSelectListener = (listenerID) => {
    const id = listenerID || ""
    const pathname = props.location.pathname; 
    const searchParams = new URLSearchParams(props.location.search); 
    searchParams.set("listener", id);
    props.history.push({
      pathname: pathname,
      search: searchParams.toString()
    })
    // Listener was selected
    setSelected(listenerID)
    // filter the listener list to show just the one item
    setSearchTerm(listenerID)
  }

  const updateState = (data) => {
    let newItems = (state.items.slice() || []).concat(data.listeners);
    // filter duplicated items
    newItems = newItems.filter( (item, pos, arr) => arr.findIndex(i => i.id == item.id)==pos );
    // create marker before sorting just in case there is any difference
    const marker = data.listeners[data.listeners.length-1]
    // sort
    newItems = newItems.sort((a, b) => a.name.localeCompare(b.name))
    setState({...state,
      items: newItems, 
      error: null,
      hasNext: data.has_next,
      marker: marker,
      updatedAt: Date.now()})
  }

  // const loadNext = event => {
  //   if(!state.isLoading && state.hasNext) {
  //     fetchListeners(loadbalancerID, state.marker)
  //   }
  // }

  const restoreUrl = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectListener()
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

  console.log("RENDER Listener list")

  const listeners =  filterItems(searchTerm, items)
  return ( 
    <div className="details-section">
      <h4>Listeners</h4>
      {error ?
        <ErrorPage headTitle="Load Balancers Listeners" error={error}/>
        :
        <React.Fragment>

          <p>Object representing the listening endpoint of a load balanced service. TCP / UDP port, as well as protocol information and other protocol- specific details are attributes of the listener. Notably, though, the IP address is not.</p>

          <div className='toolbar'>
            { selected &&
              <Link className="back-link" to="#" onClick={restoreUrl}>
                <i className="fa fa-chevron-circle-left"></i>
                Back to Listeners
              </Link>
            }
            <div className="main-buttons">
              <DefeatableLink
                disabled={selected || isLoading}
                to='/listeners/new'
                className='btn btn-primary'>
                New Listener
              </DefeatableLink>
            </div>
          </div>
          
          <table className={selected ? "table table-section listeners" : "table table-hover listeners"}>
            <thead>
                <tr>
                    <th>Name/ID</th>
                    <th>Description</th>
                    <th>State</th>
                    <th>Prov. Status</th>
                    <th>Protocol</th>
                    <th>Protocol Port</th>
                    <th>Default Pool</th>
                    <th>Connection Limit</th>
                    <th className='snug'></th>
                </tr>
            </thead>
            <tbody>
              {listeners && listeners.length>0 ?
                listeners.map( (listener, index) =>
                  <ListenerItem 
                  listener={listener} 
                  searchTerm={searchTerm} 
                  key={index} 
                  onSelectListener={onSelectListener}
                  disabled={selected ? true : false}
                  />
                )
                :
                <tr>
                  <td colSpan="8">
                    { isLoading ? <span className='spinner'/> : 'No listeners found.' }
                  </td>
                </tr>  
              }
            </tbody>
          </table>

          {selected &&
            <Policies props={props} loadbalancerID={loadbalancerID} listenerID={selected}/>
          }

          </React.Fragment>
      }
    </div>
   );
}
 
export default ListenerList