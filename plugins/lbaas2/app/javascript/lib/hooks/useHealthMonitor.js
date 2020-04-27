import React from 'react';

const useHealthMonitor = () => {

  const fetchHealthMonitor = (lbID, poolID, healthmonitorID) => {   
    return new Promise((handleSuccess,handleError) => {    
      ajaxHelper.get(`/loadbalancers/${lbID}/pools/${poolID}/healthmonitors/${healthmonitorID}`).then((response) => {      
        handleSuccess(response.data)
      }).catch( (error) => {     
        handleError(error.response)
      })      
    }) 
  }

  const persistHealthmonitor = (lbID, poolID, healthmonitorID) => {
    dispatch({type: 'RESET_HEALTHMONITORS'})
    dispatch({type: 'REQUEST_HEALTHMONITOR'})
    return new Promise((handleSuccess,handleError) => {
      fetchHealthMonitor(lbID, poolID, healthmonitorID).then((data) => {
        dispatch({type: 'RECEIVE_HEALTHMONITOR', healthmonitor: data.healthmonitor})
        handleSuccess(data)
      }).catch( error => {
        dispatch({type: 'REQUEST_HEALTHMONITOR_FAILURE', error: error})
        if(error && error.status == 404) {
          dispatch({type: 'REMOVE_HEALTHMONITOR', id: healthmonitorID})
        }   
        handleError(error.response)
      })
    })
  }

  return ( 
    fetchHealthMonitor,
    persistHealthmonitor
   );
}
 
export default useHealthMonitor;