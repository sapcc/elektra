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

  const createL7Policy = (lbID, listenerID, values) => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.post(`/loadbalancers/${lbID}/listeners/${listenerID}/l7policies`, { l7policy: values }).then((response) => {        
        handleSuccess(response)
      }).catch(error => {
        handleErrors(error)
      })
    })
  }

  const actionRedirect = (action) => {
    switch (action) {
      case 'REDIRECT_PREFIX':
        return [{value: "redirect_http_code", label: "HTTP Code"},{value: "redirect_prefix", label: "Prefix"}]
      case 'REDIRECT_TO_POOL':
        return [{value: "redirect_pool_id", label: "Pool ID"}]
      case 'REDIRECT_TO_URL':
        return [{value: "redirect_http_code", label: "HTTP Code"}, {value: "redirect_url", label: "URL"}]
      default:
        return []
    }
  }

  return {
    fetchL7Policies,
    createL7Policy,
    actionRedirect
  }
}
 
export default useL7Policy;