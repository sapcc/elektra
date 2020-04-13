import React from 'react';
import { ajaxHelper } from 'ajax_helper';
import { useDispatch } from '../../app/components/StateProvider'

const useListener = () => {
  const dispatch = useDispatch()

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

  const fetchListener = (lbID, id) => {    
    return new Promise((handleSuccess,handleError) => {    
      ajaxHelper.get(`/loadbalancers/${lbID}/listeners/${id}`).then((response) => {      
        handleSuccess(response.data)
      }).catch( (error) => {     
        handleError(error.response)
      })      
    })
  }

  const persistListeners = (lbID, marker) => {
    dispatch({type: 'RESET_LISTENERS'})
    dispatch({type: 'REQUEST_LISTENERS'})
    return new Promise((handleSuccess,handleError) => {
      fetchListeners(lbID, marker).then((data) => {
        dispatch({type: 'RECEIVE_LISTENERS', items: data.listeners, hasNext: data.has_next})
        handleSuccess(data)
      }).catch( error => {
        dispatch({type: 'REQUEST_LISTENERS_FAILURE', error: error})
        handleError(error.response)
      })
    })
  }
  
  const persistListener = (lbID, id) => {
    return new Promise((handleSuccess,handleError) => {
      fetchListener(lbID, id).then((data) => {
        dispatch({type: 'RECEIVE_LISTENER', listener: data.listener})
        handleSuccess(data)
      }).catch( error => {
        if(error && error.status == 404) {
          dispatch({type: 'REMOVE_LISTENER', id: id})
        }   
        handleError(error.response)
      })
    })
  }

  const setSearchTerm = (searchTerm) => {
    dispatch({type: 'SET_LISTENERS_SEARCH_TERM', searchTerm: searchTerm})
  }

  const setSelected = (item) => {
    dispatch({type: 'SET_LISTENERS_SELECTED_ITEM', selected: item})
  }

  const reset = () => {
    dispatch({type: 'SET_LISTENERS_SEARCH_TERM', searchTerm: null})
    dispatch({type: 'SET_LISTENERS_SELECTED_ITEM', selected: null})
  }

  return {
    fetchListeners,
    fetchListener,
    persistListeners,
    persistListener,
    setSearchTerm,
    setSelected,
    reset
  }
}

export default useListener;