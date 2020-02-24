import React from 'react'
import { useDispatch, useGlobalState } from '../StateProvider'
import { useEffect, useMemo } from 'react'
import { ajaxHelper } from 'ajax_helper';
import LoadbalancerItem from './LoadbalancerItem';
import ErrorPage from '../ErrorPage';

const LoadbalancerList = () => {
  const dispatch = useDispatch()
  const state = useGlobalState().loadbalancers
  const loadbalancers = state.items

  useEffect(() => {
    console.log('fetch initial loadbalancers')
    dispatch({type: 'REQUEST_LOADBALANCERS', requestedAt: Date.now()})
    ajaxHelper.get(`/loadbalancers`).then((response) => {
      dispatch({type: 'RECEIVE_LOADBALANCERS', items: response.data.loadbalancers, hasNext: response.data.has_next})
    })
    .catch( (error) => {
      dispatch({type: 'REQUEST_LOADBALANCERS_FAILURE', error: error})
    })
  }, []);

  return useMemo(() => {
    console.log("RENDER loadbalancer list")
    return (
      <React.Fragment>
        {state.error ?
          <ErrorPage/>
          :
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
                    key={index}
                  />
                )
                :
                <tr>
                  <td colSpan="8">
                    { state.isLoading ? <span className='spinner'/> : 'No loadbalancers found.' }
                  </td>
                </tr>  
              }
            </tbody>
          </table>
        }

      </React.Fragment>
    )
  }, [state])
  
}

export default LoadbalancerList;