import React from 'react'
import { useDispatch, useGlobalState } from '../StateProvider'
import { useEffect, useMemo } from 'react'
import { ajaxHelper } from 'ajax_helper';
import LoadbalancerItem from './LoadbalancerItem';
import ErrorPage from '../ErrorPage';
import {DefeatableLink} from 'lib/components/defeatable_link';
import { SearchField } from 'lib/components/search_field';

const LoadbalancerList = (props) => {
  const dispatch = useDispatch()
  const state = useGlobalState().loadbalancers

  useEffect(() => {
    console.log('FETCH initial loadbalancers')
    fetchLoadbalancers()
  }, []);

  const fetchLoadbalancers = () => {
    const marker = state.marker
    const params = {}
    if(marker) params['marker'] = marker.id

    dispatch({type: 'REQUEST_LOADBALANCERS', requestedAt: Date.now()})
    ajaxHelper.get(`/loadbalancers`, {params: params }).then((response) => {
      dispatch({type: 'RECEIVE_LOADBALANCERS', items: response.data.loadbalancers, hasNext: response.data.has_next})
    })
    .catch( (error) => {
      dispatch({type: 'REQUEST_LOADBALANCERS_FAILURE', error: error})
    })
  }

  const loadNext = event => {
    if(!state.isLoading && state.hasNext) {
      fetchLoadbalancers()
    }
  }

  const search = (term) => {
    if (selected) {
      // redirect
      props.history.push('/loadbalancers')
    }
    console.group("search term set")
    console.log(term)
    console.groupEnd()
  }

  const error = state.error
  const isLoading = state.isLoading
  const hasNext = state.hasNext
  const searchTerm = state.searchTerm
  const items = state.items
  const selected = state.selected

  return useMemo(() => {
    console.log("RENDER loadbalancer list")

    const filterItems = (searchTerm, items) => {
      if(!searchTerm) return items;
      // filter items
      const regex = new RegExp(searchTerm.trim(), "i");
      return items.filter((i) =>
        `${i.id} ${i.name} ${i.description}`.search(regex) >= 0
      )
    }
    const loadbalancers =  filterItems(searchTerm, items)
        
    return (
      <React.Fragment>
        {error ?
          <ErrorPage headTitle="Load Balancers" error={error}/>
          :
          <React.Fragment>
            <div className='toolbar'>
              {items.length > 0 &&
                <SearchField
                  value={searchTerm}
                  onChange={(term) => search(term)}
                  placeholder='name, ID, description' text='Searches by name, ID or description in visible loadbalancers list only.'/>                
              }
              <div className="main-buttons">
                <DefeatableLink
                  disabled={selected || isLoading}
                  to='/loadbalancers/new'
                  className='btn btn-primary'>
                  Create New
                </DefeatableLink>
              </div>
            </div>

            <table className="table loadbalancers">
              <thead>
                  <tr>
                      <th>Name/ID</th>
                      <th>Description</th>
                      <th>State</th>
                      <th>Prov. Status</th>
                      <th>Tags</th>
                      <th className="snug-nowrap">Subnet/IP Address</th>
                      <th>Listeners</th>
                      <th>Pools</th>
                      <th className='snug'></th>
                  </tr>
              </thead>
              <tbody>
                {loadbalancers && loadbalancers.length>0 ?
                  loadbalancers.map( (loadbalancer, index) =>
                    <LoadbalancerItem 
                      loadbalancer={loadbalancer}
                      disabled={selected ? true : false}
                      key={index}
                    />
                  )
                  :
                  <tr>
                    <td colSpan="8">
                      { isLoading ? <span className='spinner'/> : 'No loadbalancers found.' }
                    </td>
                  </tr>  
                }
              </tbody>
            </table>
            
            {loadbalancers.length > 0 && !selected &&
              <div className='ajax-paginate'>
                { isLoading ?
                  <div className='main-buttons'><span className="spinner"></span> Loading...</div>
                  :
                  (hasNext &&
                    <div className='main-buttons'>
                    <button className='btn btn-primary btn-sm' onClick={loadNext}>Load Next</button>
                    </div>
                  )
                }
              </div>
            }
          </React.Fragment>
        }

      </React.Fragment>
    )
  }, [items, error, isLoading, searchTerm])
  
}
export default LoadbalancerList;
