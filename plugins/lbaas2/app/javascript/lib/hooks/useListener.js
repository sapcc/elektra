import React from 'react';
import { ajaxHelper } from 'ajax_helper';

const useListener = () => {

  const fetchListeners = (lbID, marker) => {
    return new Promise((handleSuccess,handleError) => {  
      const params = {}
      if(marker) params['marker'] = marker.id
      ajaxHelper.get(`/loadbalancers/${lbID}/listeners`, {params: params }).then((response) => {
        handleSuccess(response.data)
      })
      .catch( (error) => {
        handleError(error)
      })
    })
  }

  return {
    fetchListeners
  }
}
 
export default useListener;