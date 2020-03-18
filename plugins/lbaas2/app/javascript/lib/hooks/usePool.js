import React from 'react';
import { useDispatch } from '../../app/components/StateProvider'
import { ajaxHelper } from 'ajax_helper';

const usePool = () => {
  const dispatch = useDispatch()

  const fetchPools = (lbID, marker) => {
    const params = {}
    if(marker) params['marker'] = marker.id
    dispatch({type: 'REQUEST_POOLS', requestedAt: Date.now()})
    ajaxHelper.get(`/loadbalancers/${lbID}/pools`, {params: params }).then((response) => {
      dispatch({type: 'RECEIVE_POOLS', items: response.data.pools, hasNext: response.data.has_next})
    })
    .catch( (error) => {
      dispatch({type: 'REQUEST_POOLS_FAILURE', error: error})
    })
  }

  return {
    fetchPools
  };
}
 
export default usePool;