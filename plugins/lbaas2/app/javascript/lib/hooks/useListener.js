import React from 'react';
import { ajaxHelper } from 'ajax_helper';
import { useDispatch } from '../../app/components/StateProvider'
import { confirm } from 'lib/dialogs';

const useListener = () => {
  const dispatch = useDispatch()

  const fetchListeners = (lbID, options) => {
    return new Promise((handleSuccess,handleError) => {  
      ajaxHelper.get(`/loadbalancers/${lbID}/listeners`, {params: options }).then((response) => {
        handleSuccess(response.data)
      })
      .catch( (error) => {
        handleError(error.response)
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

  const persistListeners = (lbID, shouldReset, options) => {
    if(shouldReset) {
      dispatch({type: 'RESET_LISTENERS'})
    }
    dispatch({type: 'REQUEST_LISTENERS'})
    return new Promise((handleSuccess,handleError) => {
      fetchListeners(lbID, options).then((data) => {
        dispatch({type: 'RECEIVE_LISTENERS', 
          items: data.listeners, 
          has_next: data.has_next,
          limit: data.limit,
          sort_key: data.sort_key,
          sort_dir: data.sort_dir
        })
        handleSuccess(data)
      }).catch( error => {
        dispatch({type: 'REQUEST_LISTENERS_FAILURE', error: error})
        handleError(error)
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
        handleError(error)
      })
    })
  }

  const createListener = (lbID, values) => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.post(`/loadbalancers/${lbID}/listeners`, { listener: values }).then((response) => {
        dispatch({type: 'RECEIVE_LISTENER', listener: response.data}) 
        handleSuccess(response)
      }).catch(error => {
        handleErrors(error)
      })
    })
  }

  const createNameTag = (name) => {
    return name ? <React.Fragment><b>name:</b> {name} <br/></React.Fragment> : ""
  }

  const deleteListener = (lbID, listenerID, listenerName) => {
    return new Promise((handleSuccess,handleErrors) => {
      confirm(<React.Fragment><p>Do you really want to delete following Listener?</p><p>{createNameTag(listenerName)} <b>id:</b> {listenerID}</p></React.Fragment>).then(() => {
        return ajaxHelper.delete(`/loadbalancers/${lbID}/listeners/${listenerID}`).then((response) => {
          dispatch({type: 'REQUEST_REMOVE_LISTENER', id: listenerID}) 
          handleSuccess(response)
        }).catch(error => {
          handleErrors(error)
        })
      }).catch(cancel => true)
    })
  }

  const updateListener = (lbID, listenerID, values) => {
    return new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.put(`/loadbalancers/${lbID}/listeners/${listenerID}`, { listener: values }).then((response) => {
        dispatch({type: 'RECEIVE_LISTENER', listener: response.data}) 
        handleSuccess(response)
      }).catch(error => {
        handleErrors(error)
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

  const onSelectListener = (props, listenerID) => {
    const id = listenerID || ""
    const pathname = props.location.pathname; 
    const searchParams = new URLSearchParams(props.location.search); 
    searchParams.set("listener", id);
    if (id == "") {
      // if listener was unselected then we remove the policy selection
      searchParams.set("l7policy", "");
    }
    props.history.push({
      pathname: pathname,
      search: searchParams.toString()
    })
    // Listener was selected
    setSelected(listenerID)
    // filter the listener list to show just the one item
    setSearchTerm(listenerID)
  }

  const protocolTypes = () => {
    return [
      {label: "HTTP", value: "HTTP"},
      {label: "HTTPS", value: "HTTPS"},
      {label: "TCP", value: "TCP"},
      {label: "TERMINATED_HTTPS", value: "TERMINATED_HTTPS"},
      {label: "UDP", value: "UDP"}]
  }
  
  const httpHeaderInsertions = (header) => {
    switch (header) {
      case 'X-Forwarded-For':
        return {label: "X-Forwarded-For", value: "X-Forwarded-For", description: "When selected a X-Forwarded-For header is inserted into the request to the backend member that specifies the client IP address."}
      case 'X-Forwarded-Port':
        return {label: "X-Forwarded-Port", value: "X-Forwarded-Port", description: "When selected a X-Forwarded-Port header is inserted into the request to the backend member that specifies the listener port."}
      case 'X-Forwarded-Proto':
        return {label: "X-Forwarded-Proto", value: "X-Forwarded-Proto", description: "When selected a X-Forwarded-Proto header is inserted into the request to the backend member. HTTP for the HTTP listener protocol type, HTTPS for the TERMINATED_HTTPS listener protocol type."}
      case 'X-SSL-Client-Verify':
        return {label: "X-SSL-Client-Verify", value: "X-SSL-Client-Verify", description: "When selected a X-SSL-Client-Verify header is inserted into the request to the backend member that contains 0 if the client authentication was successful, or an result error number greater than 0 that align to the openssl veryify error codes."}
      case 'X-SSL-Client-Has-Cert':
        return {label: "X-SSL-Client-Has-Cert", value: "X-SSL-Client-Has-Cert", description: "When selected a X-SSL-Client-Has-Cert header is inserted into the request to the backend member that is ‘’true’’ if a client authentication certificate was presented, and ‘’false’’ if not. Does not indicate validity."}
      case 'X-SSL-Client-DN':
        return {label: "X-SSL-Client-DN", value: "X-SSL-Client-DN", description: "When selected a X-SSL-Client-DN header is inserted into the request to the backend member that contains the full Distinguished Name of the certificate presented by the client."}
      case 'X-SSL-Client-CN':
        return {label: "X-SSL-Client-CN", value: "X-SSL-Client-CN", description: "When selected a X-SSL-Client-CN header is inserted into the request to the backend member that contains the Common Name from the full Distinguished Name of the certificate presented by the client."}
      case 'X-SSL-Issuer':
        return {label: "X-SSL-Issuer", value: "X-SSL-Issuer", description: "When selected a X-SSL-Issuer header is inserted into the request to the backend member that contains the full Distinguished Name of the client certificate issuer."}
      case 'X-SSL-Client-SHA1':
        return {label: "X-SSL-Client-SHA1", value: "X-SSL-Client-SHA1", description: "When selected a X-SSL-Client-SHA1 header is inserted into the request to the backend member that contains the SHA-1 fingerprint of the certificate presented by the client in hex string format."}
      case 'X-SSL-Client-Not-Before':
        return {label: "X-SSL-Client-Not-Before", value: "X-SSL-Client-Not-Before", description: "When selected a X-SSL-Client-Not-Before header is inserted into the request to the backend member that contains the start date presented by the client as a formatted string YYMMDDhhmmss[Z]."}
      case 'X-SSL-Client-Not-After':
        return {label: "X-SSL-Client-Not-After", value: "X-SSL-Client-Not-After", description: "When selected a X-SSL-Client-Not-After header is inserted into the request to the backend member that contains the end date presented by the client as a formatted string YYMMDDhhmmss[Z]."}
      case 'ALL':
        return [
          {label: "X-Forwarded-For", value: "X-Forwarded-For", description: "When selected a X-Forwarded-For header is inserted into the request to the backend member that specifies the client IP address."},
          {label: "X-Forwarded-Port", value: "X-Forwarded-Port", description: "When selected a X-Forwarded-Port header is inserted into the request to the backend member that specifies the listener port."},
          {label: "X-Forwarded-Proto", value: "X-Forwarded-Proto", description: "When selected a X-Forwarded-Proto header is inserted into the request to the backend member. HTTP for the HTTP listener protocol type, HTTPS for the TERMINATED_HTTPS listener protocol type."},
          {label: "X-SSL-Client-Verify", value: "X-SSL-Client-Verify", description: "When selected a X-SSL-Client-Verify header is inserted into the request to the backend member that contains 0 if the client authentication was successful, or an result error number greater than 0 that align to the openssl veryify error codes."},
          {label: "X-SSL-Client-Has-Cert", value: "X-SSL-Client-Has-Cert", description: "When selected a X-SSL-Client-Has-Cert header is inserted into the request to the backend member that is ‘’true’’ if a client authentication certificate was presented, and ‘’false’’ if not. Does not indicate validity."},
          {label: "X-SSL-Client-DN", value: "X-SSL-Client-DN", description: "When selected a X-SSL-Client-DN header is inserted into the request to the backend member that contains the full Distinguished Name of the certificate presented by the client."},
          {label: "X-SSL-Client-CN", value: "X-SSL-Client-CN", description: "When selected a X-SSL-Client-CN header is inserted into the request to the backend member that contains the Common Name from the full Distinguished Name of the certificate presented by the client."},
          {label: "X-SSL-Issuer", value: "X-SSL-Issuer", description: "When selected a X-SSL-Issuer header is inserted into the request to the backend member that contains the full Distinguished Name of the client certificate issuer."},
          {label: "X-SSL-Client-SHA1", value: "X-SSL-Client-SHA1", description: "When selected a X-SSL-Client-SHA1 header is inserted into the request to the backend member that contains the SHA-1 fingerprint of the certificate presented by the client in hex string format."},
          {label: "X-SSL-Client-Not-Before", value: "X-SSL-Client-Not-Before", description: "When selected a X-SSL-Client-Not-Before header is inserted into the request to the backend member that contains the start date presented by the client as a formatted string YYMMDDhhmmss[Z]."},
          {label: "X-SSL-Client-Not-After", value: "X-SSL-Client-Not-After", description: "When selected a X-SSL-Client-Not-After header is inserted into the request to the backend member that contains the end date presented by the client as a formatted string YYMMDDhhmmss[Z]."}
        ]
      default:
        return []
    }
  }

  const protocolHeaderInsertionRelation = (protocol) => {
    switch (protocol) {
      case 'HTTP':
        return [httpHeaderInsertions("X-Forwarded-For"), httpHeaderInsertions("X-Forwarded-Port"), httpHeaderInsertions("X-Forwarded-Proto")]
      case 'HTTPS':
        return [httpHeaderInsertions("X-Forwarded-For"), httpHeaderInsertions("X-Forwarded-Port"), httpHeaderInsertions("X-Forwarded-Proto")]
      case 'TERMINATED_HTTPS':
        return httpHeaderInsertions("ALL")
      case 'TCP':
        return []
      case 'UDP':
        return []
      case 'ALL':
        return httpHeaderInsertions("ALL")
      default:
        return []
    }
  }

  const clientAuthenticationTypes = () => {
    return [
      {label: "NONE", value: "NONE"},
      {label: "OPTIONAL", value: "OPTIONAL"},
      {label: "MANDATORY", value: "MANDATORY"}]
  }

  const clientAuthenticationRelation = (protocol) => {
    switch (protocol) {
      case 'TERMINATED_HTTPS':
        return clientAuthenticationTypes()
      default:
        return []
    }
  }

  const certificateContainerRelation = (protocol) => {
    switch (protocol) {
      case 'TERMINATED_HTTPS':
        return true
      default:
        return false
    }
  }

  const SNIContainerRelation = (protocol) => {
    switch (protocol) {
      case 'TERMINATED_HTTPS':
        return true
      default:
        return false
    }
  }

  const CATLSContainerRelation = (protocol) => {
    switch (protocol) {
      case 'TERMINATED_HTTPS':
        return true
      default:
        return false
    }
  }

  const fetchContainersForSelect = (lbID) => {    
    return new Promise((handleSuccess,handleError) => {    
      ajaxHelper.get(`/loadbalancers/${lbID}/listeners/containers`).then((response) => {      
        handleSuccess(response.data)
      }).catch( (error) => {     
        handleError(error.response)
      })      
    })
  }

  const fetchListnersNoDefaultPoolForSelect = (lbID) => {
    return new Promise((handleSuccess,handleError) => {    
      ajaxHelper.get(`/loadbalancers/${lbID}/listeners/items_no_def_pool_for_select`).then((response) => {      
        handleSuccess(response.data)
      }).catch( (error) => {     
        handleError(error.response)
      })      
    })
  }

  const fetchListnersForSelect = (lbID) => {
    return new Promise((handleSuccess,handleError) => {    
      ajaxHelper.get(`/loadbalancers/${lbID}/listeners/items_for_select`).then((response) => {      
        handleSuccess(response.data)
      }).catch( (error) => {     
        handleError(error.response)
      })      
    })
  }

  const predefinedPolicies = (protocol) => {
    switch (protocol) {
      case 'HTTP':
        return [{label: "x_forward_5b6e_v1_0", value: "x_forward_5b6e_v1_0"}, 
                {label: "no_one_connect_3caB_v1_0", value: "no_one_connect_3caB_v1_0"}, 
                {label: "http_compression_e4a2_v1_0", value: "http_compression_e4a2_v1_0"}, 
                {label: "cookie_encryption_b82a_v1_0", value: "cookie_encryption_b82a_v1_0"}, 
                {label: 'http_redirect_a26c_v1_0', value: 'http_redirect_a26c_v1_0'},
                {label: "proxy_protocol_2edF_v1_0", value: "proxy_protocol_2edF_v1_0"},
                {label: "proxy_protocol_V2_e8f6_v1_0", value: "proxy_protocol_V2_e8f6_v1_0"},
                {label: "standard_tcp_a3de_v1_0", value: "standard_tcp_a3de_v1_0"}]
      case 'TERMINATED_HTTPS':
        return [{label: "x_forward_5b6e_v1_0", value: "x_forward_5b6e_v1_0"}, 
                {label: "no_one_connect_3caB_v1_0", value: "no_one_connect_3caB_v1_0"}, 
                {label: "http_compression_e4a2_v1_0", value: "http_compression_e4a2_v1_0"}, 
                {label: "cookie_encryption_b82a_v1_0", value: "cookie_encryption_b82a_v1_0"}, 
                {label: 'sso_22b0_v1_0', value: 'sso_22b0_v1_0'},
                {label: "proxy_protocol_2edF_v1_0", value: "proxy_protocol_2edF_v1_0"},
                {label: "proxy_protocol_V2_e8f6_v1_0", value: "proxy_protocol_V2_e8f6_v1_0"},
                {label: "standard_tcp_a3de_v1_0", value: "standard_tcp_a3de_v1_0"}]
      case 'HTTPS':
      case 'TCP':
        return [{label: "proxy_protocol_2edF_v1_0", value: "proxy_protocol_2edF_v1_0"},
                {label: "proxy_protocol_V2_e8f6_v1_0", value: "proxy_protocol_V2_e8f6_v1_0"},
                {label: "standard_tcp_a3de_v1_0", value: "standard_tcp_a3de_v1_0"}]
      case 'UDP':
        return []
      default:
        return []
    }
  }

  const helpBlockItems = (protocol) => {
    return predefinedPolicies(protocol).map((item) => predPolicyDesc(item.value) )
  }

  const predPolicyDesc = (policy) => {
    switch (policy) {
      case 'proxy_protocol_2edF_v1_0':
        return {label: 'Set Proxy Protocol (proxy_protocol_2edF_v1_0)', description: <React.Fragment>Adds client IP/Port information to the TCP request <b>in text format.</b><br/>Format:  PROXY TCP[VERSION] [REMOTE ADDR] [LOCAL ADDR] [REMOTE PORT] [LOCAL PORT] <br/> For more information please take a look at <a href='https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt' target='_blank'>the Proxy Protocol Specification.</a><br/>All backend members have to have Proxy Protocol Version 1 support enabled.</React.Fragment>}
      case 'proxy_protocol_V2_e8f6_v1_0':
        return {label: 'Set Proxy Protocol V2 (proxy_protocol_V2_e8f6_v1_0)', description: <React.Fragment>Adds client IP information to the TCP request <b>strong in binary format</b>.<br/>For more information please take a look at <a href='https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt' target='_blank'>the Proxy Protocol Specification.</a><br/> All backend members have to have Proxy Protocol Version 2 support enabled.</React.Fragment>}
      case 'standard_tcp_a3de_v1_0':
        return {label: 'Use Standard Profile (standard_tcp_a3de_v1_0)', description: <React.Fragment>Switch listener from FastL4 to standard profile on F5 device. Use it only when FastL4 profile doesn't work for your application!!! <a href='https://support.f5.com/csp/article/K55185917' target='_blank'>(F5 Documentation)</a></React.Fragment>}
      case 'x_forward_5b6e_v1_0':
        return {label: 'Set X-Forwarded Headers (x_forward_5b6e_v1_0)', description: <React.Fragment>Adds X-FORWARDED-FOR/PROTO/PORT to HTTP header.</React.Fragment>}
      case 'no_one_connect_3caB_v1_0':
        return {label: 'Disable OneConnect (no_one_connect_3caB_v1_0)', description: <React.Fragment>Disables the OneConnect Profile on listeners (used for member connection reuse) <a href='https://support.f5.com/csp/article/K7208' target='_blank'>(F5 Documentation)</a></React.Fragment>}
      case 'http_compression_e4a2_v1_0':
        return {label: 'Enable HTTP compression (http_compression_e4a2_v1_0)', description: <React.Fragment>Enables HTTP compression profile on listener. Compression is done with gzip for content  types text/* and application/(xml|x-javascript).</React.Fragment>}
      case 'cookie_encryption_b82a_v1_0':
        return {label: 'Enable Cookie Encryption (cookie_encryption_b82a_v1_0)', description: <React.Fragment>All cookies are encrypted when sent to client and decrypted when passed to backend members.</React.Fragment>}
      case 'sso_22b0_v1_0':
        return {label: 'Enable Client Authentication (SSO) (sso_22b0_v1_0)', description: <React.Fragment>Prompts clients for certificates. Validates Client Ceritificates and adds various X-SSL-Client-Cert-* attributes to HTTP header. Expects listener (TERMINATED_HTTPS) certificate name used for SSL offloading starts with CATrust*</React.Fragment>}
      case 'http_redirect_a26c_v1_0':
        return {label: 'Redirect HTTP to HTTPS (http_redirect_a26c_v1_0)', description: <React.Fragment>Redirects all HTTP calls to HTTPS protocol on port 443. A given path will also be added to the https redirect, i.e. http://sap.com/hana would result in https://sap.com/hana.</React.Fragment>}
      default:
        return []
    }
  }

  const marginOnInsertHeaderAttr = (protocol) => {
    if(protocol == "HTTP" || protocol == "HTTPS"){
      return true
    }
    return false
  }

  const marginOnPredPoliciesAttr = (protocol) => {
    if(protocol == "TCP"){
      return true
    }
    return false
  }

  return {
    fetchListeners,
    fetchListener,
    persistListeners,
    persistListener,
    createListener,
    updateListener,
    deleteListener,
    onSelectListener,
    setSearchTerm,
    setSelected,
    reset,
    protocolTypes,
    httpHeaderInsertions,
    protocolHeaderInsertionRelation,
    clientAuthenticationRelation,
    fetchContainersForSelect,
    certificateContainerRelation,
    SNIContainerRelation,
    CATLSContainerRelation,
    fetchListnersForSelect,
    fetchListnersNoDefaultPoolForSelect,
    predefinedPolicies,
    helpBlockItems,
    marginOnInsertHeaderAttr,
    marginOnPredPoliciesAttr
  }
}

export default useListener;