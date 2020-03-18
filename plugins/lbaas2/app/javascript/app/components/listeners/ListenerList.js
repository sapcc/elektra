import React from 'react';
import { useDispatch, useGlobalState } from '../StateProvider'
import { useEffect } from 'react'
import useListener from '../../../lib/hooks/useListener'
import {DefeatableLink} from 'lib/components/defeatable_link';
import ListenerItem from './ListenerItem'

const ListenerList = ({loadbalancerID}) => {
  const dispatch = useDispatch()
  const state = useGlobalState().listeners  
  const {fetchListeners} = useListener()

  useEffect(() => {
    console.log('FETCH initial listeners')
    dispatch({type: 'INIT_LISTENERS'})
    fetchListeners(loadbalancerID, state.marker)
  }, []);

  const loadNext = event => {
    if(!state.isLoading && state.hasNext) {
      fetchListeners(loadbalancerID, state.marker)
    }
  }

  const error = state.error
  const isLoading = state.isLoading
  const hasNext = state.hasNext
  const searchTerm = state.searchTerm
  const items = state.items
  const selected = state.selected

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

  const listeners =  filterItems(searchTerm, items)
  return ( 
    <div className="details-section">
      <h4>Listeners</h4>
      {error ?
          <ErrorPage headTitle="Load Balancers Listeners" error={error}/>
          :
          <React.Fragment>

            <div className='toolbar'>
              <div className="main-buttons">
                <DefeatableLink
                  disabled={selected || isLoading}
                  to='/listeners/new'
                  className='btn btn-primary'>
                  New Listener
                </DefeatableLink>
              </div>
            </div>

            <table className="table table-hover listeners">
              <thead>
                  <tr>
                      <th>Name/ID</th>
                      <th>Description</th>
                      <th>Protocol</th>
                      <th>Protocol Port</th>
                      <th>Default Pool</th>
                      <th>State</th>
                      <th>Prov. Status</th>
                      <th className='snug'></th>
                  </tr>
              </thead>
              <tbody>
                {listeners && listeners.length>0 ?
                  listeners.map( (listener, index) =>
                    <ListenerItem listener={listener} searchTerm={searchTerm} key={index}/>
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

          </React.Fragment>
      }
    </div>
   );
}
 
export default ListenerList