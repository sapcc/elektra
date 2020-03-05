import React from 'react';
import { useDispatch } from '../../app/components/StateProvider'
import { ajaxHelper } from 'ajax_helper';

const useLoadbalancer = () => {
  const dispatch = useDispatch()

  const errorMessage = (err) => {
    return err.data &&  (err.data.errors || err.data.error) || err.message
  }  
  
  const fetchLoadbalancer = (id) => {    
    dispatch({type: 'REQUEST_LOADBALANCER', requestedAt: Date.now()})
    return new Promise((handleSuccess,handleError) => {    
      ajaxHelper.get(`/loadbalancers/${id}`).then((response) => {      
        dispatch({type: 'RECEIVE_LOADBALANCER', loadbalancer: response.data.loadbalancer})
        handleSuccess(response.data.loadbalancer)
      }).catch( (error) => {
        if(error.response.status == 404) {
          dispatch({type: 'REMOVE_LOADBALANCER', id: id})
        }
        handleError(error.response || error)
      })
    })
  }

  return fetchLoadbalancer

}
 
export default useLoadbalancer