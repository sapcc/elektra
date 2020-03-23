import React from 'react';
import { ajaxHelper } from 'ajax_helper';

const useL7Policy = () => {

  const fetchL7Policies = (lbID, listenerID, marker) => {
    return new Promise((handleSuccess,handleError) => {  
      const params = {}
      if(marker) params['marker'] = marker.id
      ajaxHelper.get(`/loadbalancers/${lbID}/listeners/${listenerID}/l7policies`, {params: params }).then((response) => {
        handleSuccess(response.data)
      })
      .catch( (error) => {
        handleError(error)
      })
    })
  }

  return {
    fetchL7Policies
  }
}
 
export default useL7Policy;