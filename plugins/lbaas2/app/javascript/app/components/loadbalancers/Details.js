import React from 'react';
import { useEffect } from 'react'
import { useDispatch, useGlobalState } from '../StateProvider'
import { ajaxHelper } from 'ajax_helper';

const Details = (props) => {
  const dispatch = useDispatch()
  const state = useGlobalState().loadbalancers

  useEffect(() => {
    console.log('FETCH details')
    connect()
    return function cleanup() {
      dispatch({type: 'SET_LOADBALANCER_SEARCH_TERM', searchTerm: ""})
      dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: null})
    };
  }, []);

  const connect = () => {
    let loadbalancer;
    let id = props.match && props.match.params && props.match.params.id

    if (id) {
      dispatch({type: 'SET_LOADBALANCER_SEARCH_TERM', searchTerm: id})        
      loadbalancer = state.items.find(item => item.id == id)

      if (loadbalancer) {
        console.log("DETAILS loadbalancer found")
        dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: loadbalancer})
      } else {
        console.log("DETAILS fetch loadbalancer")
        fetchLoadbalancer(id)
      }
    }
  }

  const fetchLoadbalancer = (id) => {
    dispatch({type: 'REQUEST_LOADBALANCER', requestedAt: Date.now()})
    ajaxHelper.get(`/loadbalancers/${id}`).then((response) => {
      dispatch({type: 'RECEIVE_LOADBALANCER', loadbalancer: response.data.loadbalancer})
      dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: response.data.loadbalancer})
    })
    .catch( (error) => {
      // dispatch({type: 'REQUEST_LOADBALANCERS_FAILURE', error: error})
    })
  }

  return ( 
    <React.Fragment>
      <h3>Details</h3>
    </React.Fragment>
   );
}
 
export default Details;