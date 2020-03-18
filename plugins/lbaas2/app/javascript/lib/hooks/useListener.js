import React from 'react';
import { useDispatch } from '../../app/components/StateProvider'
import { ajaxHelper } from 'ajax_helper';

const useListener = () => {
  const dispatch = useDispatch()

  const fetchListeners = (lbID, marker) => {
    const params = {}
    if(marker) params['marker'] = marker.id
    dispatch({type: 'REQUEST_LISTENERS', requestedAt: Date.now()})
    ajaxHelper.get(`/loadbalancers/${lbID}/listeners`, {params: params }).then((response) => {
      dispatch({type: 'RECEIVE_LISTENERS', items: response.data.listeners, hasNext: response.data.has_next})
    })
    .catch( (error) => {
      dispatch({type: 'REQUEST_LISTENERS_FAILURE', error: error})
    })
  }

  return {
    fetchListeners
  }
}
 
export default useListener;