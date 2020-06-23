import React from 'react';
import { ajaxHelper } from 'ajax_helper';
import { useDispatch } from '../../app/components/StateProvider'
import { confirm } from 'lib/dialogs';

const useHealthMonitor = () => {
  const dispatch = useDispatch()

  const fetchHealthmonitor = (lbID, poolID, healthmonitorID) => {   
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
      fetchHealthmonitor(lbID, poolID, healthmonitorID).then((data) => {
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

  const pollHealthmonitor = (lbID, poolID, healthmonitorID) => {
    dispatch({type: 'REQUEST_HEALTHMONITOR'})
    return new Promise((handleSuccess,handleError) => {
      fetchHealthmonitor(lbID, poolID, healthmonitorID).then((data) => {
        dispatch({type: 'RECEIVE_HEALTHMONITOR', healthmonitor: data.healthmonitor})
        handleSuccess(data)
      }).catch( error => {
        if(error && error.status == 404) {
          dispatch({type: 'REMOVE_HEALTHMONITOR', id: healthmonitorID})
        }   
        handleError(error.response)
      })
    })
  }

  
  const createHealthMonitor = (lbID, poolID, values) => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.post(`/loadbalancers/${lbID}/pools/${poolID}/healthmonitors`, { healthmonitor: values }).then((response) => {
        dispatch({type: 'RECEIVE_HEALTHMONITOR', healthmonitor: response.data}) 
        handleSuccess(response)
      }).catch(error => {
        handleErrors(error)
      })
    })
  }

  const updateHealthmonitor = (lbID, poolID, healthmonitorID, values) => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.put(`/loadbalancers/${lbID}/pools/${poolID}/healthmonitors/${healthmonitorID}`, { healthmonitor: values }).then((response) => {
        dispatch({type: 'RECEIVE_HEALTHMONITOR', healthmonitor: response.data}) 
        handleSuccess(response)
      }).catch(error => {
        handleErrors(error)
      })
    })
  }

  const createNameTag = (name) => {
    return name ? <React.Fragment><b>name:</b> {name} <br/></React.Fragment> : ""
  }

  const deleteHealthmonitor =  (lbID, poolID, healthmonitorID, healthmonitorName) => {
    return new Promise((handleSuccess,handleErrors) => {
      confirm(<React.Fragment><p>Do you really want to delete following Health Monitor?</p><p>{createNameTag(healthmonitorName)} <b>id:</b> {healthmonitorID}</p></React.Fragment>).then(() => {        
        return ajaxHelper.delete(`/loadbalancers/${lbID}/pools/${poolID}/healthmonitors/${healthmonitorID}`).then((response) => {
          dispatch({type: 'REQUEST_REMOVE_HEALTHMONITOR'})
          handleSuccess(response)
        }).catch(error => {
          handleErrors(error)
        })
      }).catch(cancel => true)
    })
  }

  // HTTP, HTTPS, PING, TCP, TLS-HELLO, or UDP-CONNECT
  const healthMonitorTypes = () => {
    return [
      {label: "HTTP", value: "HTTP"},
      {label: "HTTPS", value: "HTTPS"},
      {label: "PING", value: "PING"},
      {label: "TCP", value: "TCP"},
      {label: "TLS-HELLO", value: "TLS-HELLO"},
      {label: "UDP-CONNECT", value: "UDP-CONNECT"}
    ]
  }

  const httpMethodRelation = (type) => {
    switch (type) {
      case 'HTTP':
        return true
      case 'HTTPS':
        return true
      default:
        return false
    } 
  }

  const expectedCodesRelation = (type) => {
    switch (type) {
      case 'HTTP':
        return true
      case 'HTTPS':
        return true
      default:
        return false
    } 
  }

  const urlPathRelation = (type) => {
    switch (type) {
      case 'HTTP':
        return true
      case 'HTTPS':
        return true
      default:
        return false
    } 
  }

  const httpMethods = () => {
    return [
      {label: "CONNECT", value: "CONNECT"},
      {label: "DELETE", value: "DELETE"},
      {label: "GET", value: "GET"},
      {label: "HEAD", value: "HEAD"},
      {label: "OPTIONS", value: "OPTIONS"},
      {label: "PATCH", value: "PATCH"},
      {label: "POST", value: "POST"},
      {label: "PUT", value: "PUT"},
      {label: "TRACE", value: "TRACE"}
    ]
  }
    
  return {
    fetchHealthmonitor,
    persistHealthmonitor,
    pollHealthmonitor,
    createHealthMonitor,
    updateHealthmonitor,
    deleteHealthmonitor,
    healthMonitorTypes,
    httpMethodRelation,
    expectedCodesRelation,
    urlPathRelation,
    httpMethods
  }
}
 
export default useHealthMonitor;