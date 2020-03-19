import React from 'react';
import { ajaxHelper } from 'ajax_helper';

const usePool = () => {

  const fetchPools = (lbID, marker) => {
    return new Promise((handleSuccess,handleError) => { 
      const params = {}
      if(marker) params['marker'] = marker.id
      ajaxHelper.get(`/loadbalancers/${lbID}/pools`, {params: params }).then((response) => {
        handleSuccess(response.data)
      })
      .catch( (error) => {
        handleError(error)
      })
    })
  }

  return {
    fetchPools
  };
}
 
export default usePool;