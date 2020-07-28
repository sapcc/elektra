import React, { useState, useEffect } from 'react';
import { Modal, Button } from 'react-bootstrap';
import useCommons from '../../../lib/hooks/useCommons'
import { Form } from 'lib/elektra-form';
import useListener from '../../../lib/hooks/useListener'
import SelectInput from '../shared/SelectInput'
import ErrorPage from '../ErrorPage';
import TagsInput from '../shared/TagsInput'
import HelpPopover from '../shared/HelpPopover'
import { addNotice } from 'lib/flashes';
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'

const EditListener = (props) => {
  const {matchParams, searchParamsToString, formErrorMessage, fetchPoolsForSelect } = useCommons()
  const {fetchListener,protocolTypes,protocolHeaderInsertionRelation, clientAuthenticationRelation, fetchContainersForSelect, certificateContainerRelation, SNIContainerRelation, CATLSContainerRelation, helpBlockTextInsertHeaders, updateListener} = useListener()
  const {persistLoadbalancer} = useLoadbalancer()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [listenerID, setListenerID] = useState(null)
  
  const [protocolType, setProtocolType] = useState(null)
  const [insetHeaders, setInsertHeaders] = useState(null)
  const [CertificateContainer, setCertificateContainer] = useState(null) 
  const [SNIContainers, setSNIContainers] = useState(null) 
  const [clientAuthType, setClientAuthType] = useState(null) 
  const [defaultPoolID, setDefaultPoolID] = useState(null)
  const [clientCATLScontainer, setClientCATLScontainer] = useState(null)

  const [listener, setListener] = useState({
    isLoading: false,
    error: null,
    item: null
  })
  const [pools, setPools] = useState({
    isLoading: false,
    error: null,
    items: []
  })
  const [containers, setContainers] = useState({
    isLoading: false,
    error: null,
    items: []
  })

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const ltID = params.listenerID
    setLoadbalancerID(lbID)
    setListenerID(ltID)
  }, []);

  useEffect(() => {
    if(listenerID){
      loadListener()
    }    
  }, [listenerID]);

  const loadListener = () => {
    console.log('fetching listener to edit')
    // fetch the listener to edit
    setListener({...listener, isLoading:true, error: null})
    fetchListener(loadbalancerID, listenerID).then((data) => {
      // load the rest of attributes once we have the listener
      setSelectedProtocolType(data.listener.protocol)
      setSelectedInsertHeaders(data.listener.protocol, data.listener.insert_headers)
      setSelectedClientAuthenticationType(data.listener.protocol, data.listener.client_authentication)

      loadPools (loadbalancerID).then((availablePools) => {        
        setTimeout(() => setSelectedDefaultPoolID(availablePools, data.listener.default_pool_id), 300);        
      }).catch((error) =>{})

      loadContainers(loadbalancerID).then((availableContainers) => {
        setSelectedCertificateContainer(data.listener.protocol, availableContainers, data.listener.default_tls_container_ref)
        setSelectedSNIContainers(data.listener.protocol, availableContainers, data.listener.sni_container_refs)
        setSelectedClientCATLScontainer(data.listener.protocol, availableContainers, data.listener.client_ca_tls_container_ref)
      }).catch((error) =>{})

      setListener({...listener, isLoading:false, item: data.listener, error: null})
    })
    .catch( (error) => {      
      setListener({...listener, isLoading:false, error: error})
    })
  }  

  const setSelectedProtocolType = (selectedProtocolType) => {
    const selectedOption = protocolTypes().find(i=>i.value == (selectedProtocolType || "").trim());
    setProtocolType(selectedOption)
  }

  const setSelectedInsertHeaders = (selectedProtocolType, selecetedInsertHeaders) => {
    const availableInsertHeaders = protocolHeaderInsertionRelation(selectedProtocolType)
    setInsertHeaderSelectItems(availableInsertHeaders)
    setShowInsertHeaders( (availableInsertHeaders || []).length > 0 )
    const selectedOptions = availableInsertHeaders.filter( i => selecetedInsertHeaders.includes(i.value));
    setInsertHeaders(selectedOptions)
  }

  const setSelectedClientAuthenticationType = (selectedProtocolType, selectedClientAuthType) => {
    const availableClientAuthTypes = clientAuthenticationRelation(selectedProtocolType)
    setClientAuthenticationSelectItems(availableClientAuthTypes)
    setShowClientAuthentication( (availableClientAuthTypes || []).length > 0 )
    const selectedOption = availableClientAuthTypes.find(i=>i.value == (selectedClientAuthType || "").trim());
    setClientAuthType(selectedOption)
  }

  const setSelectedDefaultPoolID = (availablePools, selectedDefaultPoolID) => {
    const selectedOption = availablePools.find(i=>i.value == (selectedDefaultPoolID || "").trim());
    setDefaultPoolID(selectedOption)
  }

  const setSelectedCertificateContainer = (selectedProtocolType, availableContainers, selectedCertificateContainer) => {
    setShowCertificateContainer(certificateContainerRelation(selectedProtocolType))
    const selectedOption = availableContainers.find(i=>i.value == (selectedCertificateContainer || "").trim());
    setCertificateContainer(selectedOption)
  }

  const setSelectedSNIContainers = (selectedProtocolType, availableContainers, selectedSNIContainers) => {
    setShowSNIContainer(SNIContainerRelation(selectedProtocolType))
    const selectedOptions = availableContainers.filter( i => selectedSNIContainers.includes(i.value));
    setSNIContainers(selectedOptions)
  }

  const setSelectedClientCATLScontainer = (selectedProtocolType, availableContainers, selectedCATLSContainer) => {
    setShowCATLSContainer(CATLSContainerRelation(selectedProtocolType))
    const selectedOption = availableContainers.find(i=>i.value == (selectedCATLSContainer || "").trim());
    setClientCATLScontainer(selectedOption)
  }

  const loadPools = (lbID) => {
    return new Promise((handleSuccess,handleErrors) => {
      setPools({...pools, isLoading:true})
      fetchPoolsForSelect(lbID).then((data) => {
        setPools({...pools, isLoading:false, items: data.pools, error: null})
        handleSuccess(data.pools)
      })
      .catch( (error) => {      
        setPools({...pools, isLoading:false, error: error})
        handleErrors(error)
      })
    })
  }

  const loadContainers = (lbID, selectedCertificateContainer, selectedSNIContainers, selectedCATLSContainer) => {
    return new Promise((handleSuccess,handleErrors) => {
      setContainers({...containers, isLoading:true})
      fetchContainersForSelect(lbID).then((data) => {
        setContainers({...containers, isLoading:false, items: data.containers, error: null})
        handleSuccess(data.containers)
      })
      .catch( (error) => {      
        setContainers({...containers, isLoading:false, error: error})
        handleErrors(error)
      })
    })
  }

  /*
  * Modal stuff
  */
  const [show, setShow] = useState(true)

  const close = (e) => {
    if(e) e.stopPropagation()
    setShow(false)
  }

  const restoreUrl = () => {
    if (!show){ 
      // get the lb
      const params = matchParams(props)
      const lbID = params.loadbalancerID
      props.history.replace(`/loadbalancers/${lbID}/show?${searchParamsToString(props)}`)
    }
  }

    /**
   * Form stuff
   */
  const [formErrors,setFormErrors] = useState(null)
  const [insetHeaderSelectItems, setInsertHeaderSelectItems] = useState([])
  const [clientAuthenticationSelectItems, setClientAuthenticationSelectItems] = useState([])

  const [showInsertHeaders, setShowInsertHeaders] = useState(false)
  const [showClientAuthentication, setShowClientAuthentication] = useState(false)
  const [showCertificateContainer, setShowCertificateContainer] = useState(false)
  const [showSNIContainer, setShowSNIContainer] = useState(false)
  const [showCATLSContainer, setShowCATLSContainer] = useState(false)

  const validate = ({name,description,protocol_port,protocol,default_pool_id,connection_limit,insert_headers,default_tls_container_ref, sni_container_refs,client_authentication,client_ca_tls_container_ref,tags}) => {
    return name && protocol_port && protocol && true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    return updateListener(loadbalancerID, listenerID, values).then((response) => {
      addNotice(<React.Fragment>Listener <b>{response.data.name}</b> ({response.data.id}) is being updated.</React.Fragment>)
      // fetch the lb again containing the new listener so it gets updated fast
      persistLoadbalancer(loadbalancerID).catch(error => {
      })
      close()
    }).catch(error => {
      setFormErrors(formErrorMessage(error))
    })
  }

  const onSelectDefaultPoolChange = (props) => {setDefaultPoolID(props)}
  const onSelectInsertHeadersChange = (props) => {setInsertHeaders(props)}
  const onSelectClientAuthentication = (props) => {setClientAuthType(props)}
  const onSelectCertificateContainer = (props) => {setCertificateContainer(props)}
  const onSelectSNIContainers = (props) => {setSNIContainers(props)}
  const onSelectCATLSContainers = (props) => {setClientCATLScontainer(props)}

  console.log("RENDER edit listener")
  return ( 
    <Modal
      show={show}
      onHide={close}
      bsSize="large"
      backdrop='static'
      onExited={restoreUrl}
      aria-labelledby="contained-modal-title-lg"
      bsClass="lbaas2 modal">
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">Edit Listener</Modal.Title>
      </Modal.Header>

      {listener.error ?
        <Modal.Body>
          <ErrorPage headTitle="Edit Listener" error={listener.error} onReload={loadListener}/>
        </Modal.Body>
      :
        <React.Fragment>
          {listener.isLoading ? 
              <Modal.Body>
                <span className='spinner'/>
              </Modal.Body>
            :
            <Form
              className='form form-horizontal'
              validate={validate}
              onSubmit={onSubmit}
              initialValues={listener.item}
              resetForm={false}>

              <Modal.Body>
                <p>A Listener defines a protocol/port combination under which the load balancer can be called.</p>
                <Form.Errors errors={formErrors}/>
                <Form.ElementHorizontal label='Name' name="name" required>
                  <Form.Input elementType='input' type='text' name='name'/>
                </Form.ElementHorizontal>
                <Form.ElementHorizontal label='Description' name="description">
                <Form.Input elementType='input' type='text' name='description'/>
                </Form.ElementHorizontal>
                <Form.ElementHorizontal label='Protocol Port' name="protocol_port" required>
                  <Form.Input elementType='input' type='number' min="1" max="65535" name='protocol_port' disabled={true}/>
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    The port under which the load balancer can be called. A port number between 1 and 65535.
                  </span>
                </Form.ElementHorizontal>
                <Form.ElementHorizontal label='Protocol' name="protocol" required>
                  <SelectInput name="protocol" items={protocolTypes()} value={protocolType} isDisabled={true} />
                    <span className="help-block">
                      <i className="fa fa-info-circle"></i>
                      The protocol which can be used to access the load balancer port.
                    </span>
                  </Form.ElementHorizontal>
                  <Form.ElementHorizontal label='Default Pool' name="default_pool_id">
                    <SelectInput name="default_pool_id" isLoading={pools.isLoading} items={pools.items} onChange={onSelectDefaultPoolChange} value={defaultPoolID} isClearable/>
                    { pools.error ? <span className="text-danger">{pools.error}</span>:""}
                    <span className="help-block">
                      <i className="fa fa-info-circle"></i>
                      The pool to which all traffic will be routed if no L7 Policy defines a different pool.
                    </span>
                  </Form.ElementHorizontal>
                  <Form.ElementHorizontal label='Connection Limit' name="connection_limit">
                    <Form.Input elementType='input' type='number' min="-1" name='connection_limit'/>
                    <span className="help-block">
                      <i className="fa fa-info-circle"></i>
                      The number of parallel connections allowed to access the load balancer. Value -1 means infinite connections are allowed.
                    </span>
                  </Form.ElementHorizontal>

                  {showInsertHeaders &&
                    <Form.ElementHorizontal label='Insert Headers' name="insert_headers">
                      <SelectInput name="insert_headers" items={insetHeaderSelectItems} isMulti onChange={onSelectInsertHeadersChange} value={insetHeaders}/>
                        <span className="help-block">
                          <i className="fa fa-info-circle"></i>
                          <span className="help-block-text">Headers to insert into the request before it is sent to the backend member.</span>
                          <HelpPopover text={helpBlockTextInsertHeaders()} />
                        </span>
                    </Form.ElementHorizontal>
                  }

                  {showCertificateContainer &&
                    <Form.ElementHorizontal label='Certificate Container' name="default_tls_container_ref" required>
                    { containers.error ? <span className="text-danger">{containers.error}</span>:""}
                      <SelectInput name="default_tls_container_ref" isLoading={containers.isLoading}  items={containers.items} onChange={onSelectCertificateContainer} value={CertificateContainer} isClearable/>
                        <span className="help-block">
                          <i className="fa fa-info-circle"></i>
                          The container with the TLS secrets used for the listener.
                        </span>
                    </Form.ElementHorizontal>
                  }

                  {showSNIContainer &&
                    <Form.ElementHorizontal label='SNI Containers' name="sni_container_refs">
                    { containers.error ? <span className="text-danger">{containers.error}</span>:""}
                      <SelectInput name="sni_container_refs" isLoading={containers.isLoading} isMulti items={containers.items} onChange={onSelectSNIContainers} value={SNIContainers}/>
                        <span className="help-block">
                          <i className="fa fa-info-circle"></i>
                          A list of containers with alternative TLS secrets used for Server Name Indication (SNI).
                        </span>
                    </Form.ElementHorizontal>
                  }

                  {showClientAuthentication &&
                    <Form.ElementHorizontal label='Client Authentication Mode' name="client_authentication">
                      <SelectInput name="client_authentication" items={clientAuthenticationSelectItems} onChange={onSelectClientAuthentication} value={clientAuthType} isClearable/>
                        <span className="help-block">
                          <i className="fa fa-info-circle"></i>
                          The TLS client authentication mode.
                        </span>
                    </Form.ElementHorizontal>
                  }

                  {showCATLSContainer &&
                    <Form.ElementHorizontal label='Client Authentication Container' name="client_ca_tls_container_ref">
                      <SelectInput name="client_ca_tls_container_ref" isLoading={containers.isLoading}  items={containers.items} onChange={onSelectCATLSContainers} value={clientCATLScontainer} isClearable/>
                        <span className="help-block">
                          <i className="fa fa-info-circle"></i>
                          The TLS client authentication certificate.
                        </span>
                    </Form.ElementHorizontal>
                  }

                  <Form.ElementHorizontal label='Tags' name="tags">
                    <TagsInput name="tags" initValue={listener.item && listener.item.tags}/>
                    <span className="help-block">
                      <i className="fa fa-info-circle"></i>
                      Start a new tag typing a string and hitting the Enter or Tab key.
                    </span>
                  </Form.ElementHorizontal>
              </Modal.Body>

              <Modal.Footer>  
                <Button onClick={close}>Cancel</Button>
                <Form.SubmitButton label='Save'/>
              </Modal.Footer>

            </Form>
          }
        </React.Fragment>
      }
    </Modal>
   );
}
 
export default EditListener;