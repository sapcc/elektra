import React from 'react'
import { useDispatch, useGlobalState } from './StateProvider'
import { useEffect } from 'react'
import { ajaxHelper } from 'ajax_helper';
import LoadbalancerItem from './loadbalancerItem';

const LoadbalancerList = () => {
  const dispatch = useDispatch()
  const state = useGlobalState().loadbalancers
  const items = state.items

  useEffect(() => {
    console.log('fetch loadbalancers')
    dispatch({type: 'REQUEST_LOADBALANCERS', requestedAt: Date.now()})
    ajaxHelper.get(`/loadbalancers`).then((response) => {
      if (response.data.errors) {
        dispatch({
          type: 'REQUEST_LOADBALANCERS_FAILURE', 
          error: {status: error.response.status, name: error.response.statusText, message: error.response.data}
          })
      }else {
        dispatch({type: 'RECEIVE_LOADBALANCERS', items: response.data.loadbalancers, hasNext: response.data.has_next})        
      }
    }).catch(error => {
      dispatch({type: 'REQUEST_LOADBALANCERS_FAILURE', error: {message: error.message}})
    })
  }, []);

  return (    
    <table className="table loadbalancers">
      <thead>
          <tr>
              <th>Name/ID</th>
              <th>Description</th>
              <th>State</th>
              <th>Prov. Status</th>
              <th className="snug-nowrap">Subnet <small>(associated from cache)</small>/IP Address</th>
              <th>Listeners</th>
              <th>Pools</th>
              <th className='snug'></th>
          </tr>
      </thead>
      <tbody>
        {items && items.length>0 ?
          items.map( (loadbalancer, index) =>
            <LoadbalancerItem 
              loadbalancer={loadbalancer}
              key={index}
            />
          )
          :
          <tr>
            <td colSpan="7">
              { state.isLoading ? <span className='spinner'/> : 'No loadbalancers found.' }
            </td>
          </tr>  
        }
      </tbody>
    </table>
  )

}

export default LoadbalancerList;