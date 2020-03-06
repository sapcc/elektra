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
    return new Promise((handleSuccess,handleError) => {    
      ajaxHelper.get(`/loadbalancers/${id}`).then((response) => {      
        dispatch({type: 'RECEIVE_LOADBALANCER', loadbalancer: response.data.loadbalancer})
        handleSuccess(response.data.loadbalancer)
      }).catch( (error) => {   
        console.error(error)
        if (!reason.isCanceled) { // promise is not canceled
          if(error.response.status == 404) {
            dispatch({type: 'REMOVE_LOADBALANCER', id: id})
          } 
        }  
      })
    })
  }

  const createLoadbalancer = (values) => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.post('/loadbalancers/', { loadbalancer: values }).then((response) => {
        dispatch({type: 'RECEIVE_LOADBALANCER', loadbalancer: response.data})        
        handleSuccess(response)
      }).catch(error => {
        handleErrors(error)
      })
    })
  }

  const deleteLoadbalancer = (id) => {
    confirm(`Do you really want to delete the loadbalancer ${id}?`).then(() => {
      return ajaxHelper.delete(`/loadbalancers/${id}`)
      .then( (response) => {
        dispatch({type: 'REQUEST_REMOVE_LOADBALANCER', id: id})
        addNotice("Load Balancer " + id + " will be deleted.")
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
    deleteLoadbalancer,
    createLoadbalancer
  }

}
 
export default useLoadbalancer