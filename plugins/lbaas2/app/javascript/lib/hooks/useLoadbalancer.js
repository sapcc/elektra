import React from 'react';
import { useDispatch } from '../../app/components/StateProvider'
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';

const useLoadbalancer = () => {
  const dispatch = useDispatch()

  const errorMessage = (err) => {
    return err.data &&  (err.data.errors || err.data.error) || err.message
  }  
 
  const fetchLoadbalancers = (options) => {
    dispatch({type: 'REQUEST_LOADBALANCERS', requestedAt: Date.now()})
    ajaxHelper.get(`/loadbalancers`, {params: options }).then((response) => {
      dispatch({type: 'RECEIVE_LOADBALANCERS',  
        loadbalancers: response.data.loadbalancers, 
        has_next: response.data.has_next,
        limit: response.data.limit,
        sort_key: response.data.sort_key,
        sort_dir: response.data.sort_dir
      })
    })
    .catch( (error) => {
      dispatch({type: 'REQUEST_LOADBALANCERS_FAILURE', error: error})
    })
  }

  const fetchLoadbalancer = (id) => {    
    return new Promise((handleSuccess,handleError) => {    
      ajaxHelper.get(`/loadbalancers/${id}`).then((response) => {      
        dispatch({type: 'RECEIVE_LOADBALANCER', loadbalancer: response.data.loadbalancer})
        handleSuccess(response.data.loadbalancer)
      }).catch( (error) => {
        if(error.response && error.response.status == 404) {
          dispatch({type: 'REMOVE_LOADBALANCER', id: id})
        }        
        handleError(error.response)
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

  const createNameTag = (name) => {
    return name ? <React.Fragment><b>name:</b> {name} <br/></React.Fragment> : ""
  }
  
  const deleteLoadbalancer = (name, id) => {
    return new Promise((handleSuccess,handleErrors) => {
      confirm(<React.Fragment><p>Do you really want to delete following Load Balancer?</p><p>{createNameTag(name)} <b>id:</b> {id}</p></React.Fragment>).then(() => {
        return ajaxHelper.delete(`/loadbalancers/${id}`)
        .then( (response) => {
          dispatch({type: 'REQUEST_REMOVE_LOADBALANCER', id: id})
          handleSuccess(response)
        })
        .catch( (error) => {     
          handleErrors(error)
        });
      }).catch(cancel => true)
    })
  }

  const fetchSubnets = (id) => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.get(`/loadbalancers/private-networks/${id}/subnets`).then((response) => {
        handleSuccess(response.data.subnets)
      }).catch(error => {
        handleErrors(error.response)
      })
    })
  }

  const fetchFloatingIPs = () => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.get(`/loadbalancers/fips`).then((response) => {
        handleSuccess(response.data.fips)
      }).catch(error => {
        handleErrors(error.response)
      })
    })
  }

  const attachFIP = (lbID, values) => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.post(`/loadbalancers/${lbID}/attach_fip`, values).then((response) => {
        dispatch({type: 'RECEIVE_LOADBALANCER', loadbalancer: response.data})
        handleSuccess(response)
      }).catch(error => {
        handleErrors(error)
      })
    })
  }

  return {
    fetchLoadbalancers,
    fetchLoadbalancer,
    deleteLoadbalancer,
    createLoadbalancer,
    fetchSubnets,
    fetchFloatingIPs,
    attachFIP
  }

}
 
export default useLoadbalancer