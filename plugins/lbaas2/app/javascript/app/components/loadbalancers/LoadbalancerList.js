import React from 'react'
import { useDispatch, useGlobalState } from '../StateProvider'
import { useEffect, useMemo } from 'react'
import { ajaxHelper } from 'ajax_helper';
import LoadbalancerItem from './LoadbalancerItem';
import ErrorPage from '../ErrorPage';
import {DefeatableLink} from 'lib/components/defeatable_link';

const LoadbalancerList = () => {
  const dispatch = useDispatch()
  const state = useGlobalState().loadbalancers
  const loadbalancers = state.items
  const error = state.error
  const isLoading = state.isLoading

  useEffect(() => {
    console.log('fetch initial loadbalancers')
    dispatch({type: 'REQUEST_LOADBALANCERS', requestedAt: Date.now()})
    ajaxHelper.get(`/loadbalancers`).then((response) => {
      dispatch({type: 'RECEIVE_LOADBALANCERS', items: response.data.loadbalancers, hasNext: response.data.has_next})
    })
    .catch( (error) => {
      dispatch({type: 'REQUEST_LOADBALANCERS_FAILURE', error: error.response})
    })
  }, []);

  return useMemo(() => {
    console.log("RENDER loadbalancer list")
    return (
      <React.Fragment>
        {error ?
          <ErrorPage headTitle="Load Balancers" error={error}/>
          :
          <React.Fragment>
            <div className='toolbar'>
              <div className="main-buttons">
                <DefeatableLink
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
          </React.Fragment>
        }

      </React.Fragment>
    )
  }, [loadbalancers, error, isLoading])
  
}

export default LoadbalancerList;