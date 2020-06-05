import React from 'react';
import { ajaxHelper } from 'ajax_helper';
import { useDispatch } from '../../app/components/StateProvider'
import { confirm } from 'lib/dialogs';

const useL7Policy = () => {
  const dispatch = useDispatch()

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

  const fetchL7Policy = (lbID, listenerID, l7PolicyID) => {
    return new Promise((handleSuccess,handleError) => {    
      ajaxHelper.get(`/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}`).then((response) => {      
        handleSuccess(response.data)
      }).catch( (error) => {     
        handleError(error.response)
      })      
    })
  }

  const persistL7Policies = (lbID, listenerID, marker) => {
    dispatch({type: 'RESET_L7POLICIES'})
    dispatch({type: 'REQUEST_L7POLICIES'})
    return new Promise((handleSuccess,handleError) => {
      fetchL7Policies(lbID, listenerID, marker).then((data) => {
        dispatch({type: 'RECEIVE_L7POLICIES', items: data.l7policies, hasNext: data.has_next})
        handleSuccess(data)
      }).catch( error => {
        dispatch({type: 'REQUEST_L7POLICIES_FAILURE', error: error})
        handleError(error.response)
      })
    })
  }

  const persistL7Policy = (lbID, listenerID, l7PolicyID) => {
    return new Promise((handleSuccess,handleError) => {
      fetchL7Policy(lbID, listenerID, l7PolicyID).then((data) => {
        dispatch({type: 'RECEIVE_L7POLICY', l7Policy: data.l7policy})
        handleSuccess(data)
      }).catch( error => {
        if(error && error.status == 404) {
          dispatch({type: 'REMOVE_L7POLICY', id: l7PolicyID})
        }   
        handleError(error.response)
      })
    })
  }

  const createL7Policy = (lbID, listenerID, values) => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.post(`/loadbalancers/${lbID}/listeners/${listenerID}/l7policies`, { l7policy: values }).then((response) => {        
        dispatch({type: 'RECEIVE_L7POLICY', l7Policy: response.data}) 
        handleSuccess(response)
      }).catch(error => {
        handleErrors(error)
      })
    })
  }


  const createNameTag = (name) => {
    return name ? <React.Fragment><b>name:</b> {name} <br/></React.Fragment> : ""
  }
  
  const deleteL7Policy = (lbID, listenerID, l7policyID, l7policyName) => {
    return new Promise((handleSuccess,handleErrors) => {
      confirm(<React.Fragment><p>Do you really want to delete following L7 Policy?</p><p>{createNameTag(l7policyName)} <b>id:</b> {l7policyID}</p></React.Fragment>).then(() => {
        return ajaxHelper.delete(`/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7policyID}`).then((response) => {
          dispatch({type: 'REQUEST_REMOVE_L7POLICY', id: l7policyID})
          handleSuccess(response)
        }).catch(error => {
          handleErrors(error)
        })
      }).catch(cancel => true)
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

  const setSearchTerm = (searchTerm) => {
    dispatch({type: 'SET_L7POLICIES_SEARCH_TERM', searchTerm: searchTerm})
  }

  const setSelected = (item) => {
    dispatch({type: 'SET_L7POLICIES_SELECTED_ITEM', selected: item})
  }

  const reset = () => {
    dispatch({type: 'SET_L7POLICIES_SEARCH_TERM', searchTerm: null})
    dispatch({type: 'SET_L7POLICIES_SELECTED_ITEM', selected: null})
  }

  return {
    fetchL7Policies,
    fetchL7Policy,
    createL7Policy,
    deleteL7Policy,
    actionRedirect,
    persistL7Policies,
    persistL7Policy,
    setSearchTerm,
    setSelected,
    reset
  }
}
 
export default useL7Policy;