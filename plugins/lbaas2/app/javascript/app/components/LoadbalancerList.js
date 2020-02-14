import React from 'react'
import { useDispatch, useGlobalState } from './StateProvider'
import { useEffect } from 'react'
import { ajaxHelper } from 'ajax_helper';
import LoadbalancerItem from './LoadbalancerItem';
import Unavailable from './Unavailable';

const LoadbalancerList = () => {
  const dispatch = useDispatch()
  const state = useGlobalState().loadbalancers
  const items = state.items

  const errorMessage = (error) =>
    error.response && error.response.data && (error.response.data.errors || error.response.data.error) ||
    error.message

  useEffect(() => {
    console.log('fetch loadbalancers')
    dispatch({type: 'REQUEST_LOADBALANCERS', requestedAt: Date.now()})
    ajaxHelper.get(`/loadbalancers`).then((response) => {
      dispatch({type: 'RECEIVE_LOADBALANCERS', items: response.data.loadbalancers, hasNext: response.data.has_next})
    })
    .catch( (error) => {
      console.log("error loading loadbalancers -->" + error.response.data.error)
      dispatch({type: 'REQUEST_LOADBALANCERS_FAILURE', error: errorMessage(error)})
    })
  }, []);

  return (
    <React.Fragment>
      { state.isLoading ? 
        <span className='spinner'/> 
        :
        <React.Fragment>
          { state.error ? 
            <h1>Snap!
              {/* <Unavailable errorMessage={state.error} /> */}
            </h1>            
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
                {items && items.length>0 ?
                  items.map( (loadbalancer, index) =>
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
      }
    </React.Fragment>
  )

}

export default LoadbalancerList;