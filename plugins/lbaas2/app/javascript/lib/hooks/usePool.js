import React from 'react';
import { ajaxHelper } from 'ajax_helper';
import { useDispatch } from '../../app/components/StateProvider'

const usePool = () => {
  const dispatch = useDispatch()

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

  const persistPools = (lbID, marker) => {
    dispatch({type: 'RESET_POOLS'})
    dispatch({type: 'REQUEST_POOLS'})
    return new Promise((handleSuccess,handleError) => {
      fetchPools(lbID, marker).then((data) => {
        dispatch({type: 'RECEIVE_POOLS', items: data.pools, hasNext: data.has_next})
        handleSuccess(data)
      }).catch( error => {
        dispatch({type: 'REQUEST_POOLS_FAILURE', error: error})
        handleError(error.response)
      })
    })
  }
  
  const setSearchTerm = (searchTerm) => {
    dispatch({type: 'SET_POOLS_SEARCH_TERM', searchTerm: searchTerm})
  }

  const setSelected = (item) => {
    dispatch({type: 'SET_POOLS_SELECTED_ITEM', selected: item})
  }

  const reset = () => {
    dispatch({type: 'SET_POOLS_SEARCH_TERM', searchTerm: null})
    dispatch({type: 'SET_POOLS_SELECTED_ITEM', selected: null})
  }

  return {
    fetchPools,
    persistPools,
    setSearchTerm,
    setSelected,
    reset
  };
}
 
export default usePool;