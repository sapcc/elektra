import React from 'react';
import { ajaxHelper } from 'ajax_helper';
import { useDispatch } from '../../app/components/StateProvider'

const useL7Rule = () => {
  const dispatch = useDispatch()

  const fetchL7Rules = (lbID, listenerID, l7Policy, marker) => {
    return new Promise((handleSuccess,handleError) => {  
      const params = {}
      if(marker) params['marker'] = marker.id
      ajaxHelper.get(`/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7Policy}/l7rules`, {params: params }).then((response) => {
        handleSuccess(response.data)
      })
      .catch( (error) => {
        handleError(error)
      })
    })
  }

  const persistL7Rules = (lbID, listenerID, l7Policy, marker) => {
    dispatch({type: 'RESET_L7RULES'})
    dispatch({type: 'REQUEST_L7RULES'})
    return new Promise((handleSuccess,handleError) => {
      fetchL7Rules(lbID, listenerID, l7Policy, marker).then((data) => {
        dispatch({type: 'RECEIVE_L7RULES', items: data.l7rules, hasNext: data.has_next})
        handleSuccess(data)
      }).catch( error => {
        dispatch({type: 'REQUEST_L7RULES_FAILURE', error: error})
        handleError(error.response)
      })
    })
  }

  return {
    fetchL7Rules,
    persistL7Rules
  }
}
 
export default useL7Rule;