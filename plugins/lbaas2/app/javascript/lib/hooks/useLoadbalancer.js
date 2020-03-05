import React from 'react';
import { useDispatch } from '../../app/components/StateProvider'
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

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

  const deleteLoadbalancer = (id) => {
    confirm(`Do you really want to delete the loadbalancer ${id}?`).then(() => {
      return ajaxHelper.delete(`/loadbalancers/${id}`)
      .then( (response) => {
        dispatch({type: 'REQUEST_REMOVE_LOADBALANCER', loadbalancer: id})
        addNotice('Load Balancer will be deleted.')
      })
      .catch( (error) => {     
        addError(React.createElement(ErrorsList, {
          errors: errorMessage(error.response)
        }))
      });
    }).catch(cancel => true)
  }

  return {
    fetchLoadbalancer,
    deleteLoadbalancer
  }

}
 
export default useLoadbalancer