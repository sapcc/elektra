import React, { useState,useEffect} from 'react';
import useCommons from '../../../lib/hooks/useCommons'
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import useListener from '../../../lib/hooks/useListener'
import SelectInput from '../shared/SelectInput'
import TagsInput from '../shared/TagsInput'
import HelpPopover from '../shared/HelpPopover'
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'
import { addNotice } from 'lib/flashes';

const NewListener = (props) => {
  const {searchParamsToString, matchParams,fetchPoolsForSelect,formErrorMessage} = useCommons()
  const {protocolTypes, protocolHeaderInsertionRelation, clientAuthenticationRelation, fetchContainersForSelect, certificateContainerRelation, SNIContainerRelation, CATLSContainerRelation, httpHeaderInsertions, createListener} = useListener()
  const {persistLoadbalancer} = useLoadbalancer()
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
    console.log('fetching pools and containers for select')
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    // get pools for the select
    setPools({...pools, isLoading:true})
    fetchPoolsForSelect(lbID).then((data) => {
      setPools({...pools, isLoading:false, items: data.pools, error: null})
    })
    .catch( (error) => {      
      setPools({...pools, isLoading:false, error: error})
    })

    // get the containers for the select
    setContainers({...containers, isLoading:true})
    fetchContainersForSelect(lbID).then((data) => {
      setContainers({...containers, isLoading:false, items: data.containers, error: null})
    })
    .catch( (error) => {      
      setContainers({...containers, isLoading:false, error: error})
    })
  }, []);

  /**
   * Modal stuff
   */
  const [show, setShow] = useState(true)

  const close = (e) => {
    if(e) e.stopPropagation()
    setShow(false)
  }

  const restoreUrl = () => {
    if (!show){
      const params = matchParams(props)
      const lbID = params.loadbalancerID
      props.history.replace(`/loadbalancers/${lbID}/show?${searchParamsToString(props)}`)
    }
  }

    /*
  * Form stuff
  */
  const [formErrors,setFormErrors] = useState(null)
  const [initialValues, setInitialValues] = useState({connection_limit: -1})
  const [insetHeaderSelectItems, setInsertHeaderSelectItems] = useState([])
  const [clientAuthenticationSelectItems, setClientAuthenticationSelectItems] = useState([])
  const [showCertificateContainer, setShowCertificateContainer] = useState(false)
  const [showSNIContainer, setShowSNIContainer] = useState(false)
  const [showCATLSContainer, setShowCATLSContainer] = useState(false)

  const validate = ({name,description,protocol_port,protocol,default_pool_id,connection_limit,insert_headers,default_tls_container_ref, sni_container_refs,client_authentication,client_ca_tls_container_ref,tags}) => {
    return name && protocol_port && protocol && true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    // save the entered values in case of error
    setInitialValues(values)
    // get the lb id
    const params = matchParams(props)
    const lbID = params.loadbalancerID

    return createListener(lbID, values).then((response) => {
      addNotice(<React.Fragment>Listener <b>{response.data.name}</b> ({response.data.id}) is being created.</React.Fragment>)
      // fetch the lb again containing the new listener so it gets updated fast
      persistLoadbalancer(lbID).catch(error => {
      })
      // TODO: if the listener contains a pool then fetch the pool again so it gets updated
      close()
    }).catch(error => {
      setFormErrors(formErrorMessage(error))
    })
  }

  const onSelectProtocolType = (props) => {
    if (props) {
      setInsertHeaderSelectItems(protocolHeaderInsertionRelation(props.value))
      setClientAuthenticationSelectItems(clientAuthenticationRelation(props.value))
      setShowCertificateContainer(certificateContainerRelation(props.value))
      setShowSNIContainer(SNIContainerRelation(props.value))
      setShowCATLSContainer(CATLSContainerRelation(props.value))
    } else {
      setInsertHeaderSelectItems([])
      setClientAuthenticationSelectItems([])
      setShowCertificateContainer(false)
      setShowSNIContainer(false)
      setShowCATLSContainer(false)
    }
  }
  const onSelectPoolChange = (props) => {}
  const onSelectInsertHeadersChange = (props) => {}
  const onSelectClientAuthentication = (props) => {}
  const onSelectCertificateContainer = (props) => {}
  const onSelectSNIContainers = (props) => {}
  const onSelectCATLSContainers = (props) => {}

  const helpBlockTextInsertHeaders = () => {
    return (
      <ul className="help-block-popover-scroll">
        {httpHeaderInsertions("ALL").map( (t, index) =>
          <li key={index}>{t.label}: {t.description}</li>
        )}
      </ul>
    )
  }

  console.log("RENDER new listener")
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
        <Modal.Title id="contained-modal-title-lg">New Listener</Modal.Title>
      </Modal.Header>

      <Form
        className='form form-horizontal'
        validate={validate}
        onSubmit={onSubmit}
        initialValues={initialValues}
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
            <Form.Input elementType='input' type='number' min="1" max="65535" name='protocol_port'/>
            <span className="help-block">
              <i className="fa fa-info-circle"></i>
              The port under which the load balancer can be called. A port number between 1 and 65535.
            </span>
          </Form.ElementHorizontal>
          <Form.ElementHorizontal label='Protocol' name="protocol" required>
          <SelectInput name="protocol" items={protocolTypes()} onChange={onSelectProtocolType} />
            <span className="help-block">
              <i className="fa fa-info-circle"></i>
              The protocol which can be used to access the load balancer port.
            </span>
          </Form.ElementHorizontal>
          <Form.ElementHorizontal label='Default Pool' name="default_pool_id">
            <SelectInput name="default_pool_id" isLoading={pools.isLoading} items={pools.items} onChange={onSelectPoolChange} />
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

          {insetHeaderSelectItems.length > 0 &&
            <Form.ElementHorizontal label='Insert Headers' name="insert_headers">
              <SelectInput name="insert_headers" items={insetHeaderSelectItems} isMulti onChange={onSelectInsertHeadersChange} />
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  <span className="help-block-text">Headers to insert into the request before it is sent to the backend member.</span>
                  <HelpPopover text={helpBlockTextInsertHeaders()} />
                </span>
            </Form.ElementHorizontal>
          }

          {showCertificateContainer &&
            <Form.ElementHorizontal label='Certificate Container' name="default_tls_container_ref">
            { containers.error ? <span className="text-danger">{containers.error}</span>:""}
              <SelectInput name="default_tls_container_ref" isLoading={containers.isLoading}  items={containers.items} onChange={onSelectCertificateContainer} />
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  The container with the TLS secrets used for the listener.
                </span>
            </Form.ElementHorizontal>
          }

          {showSNIContainer &&
            <Form.ElementHorizontal label='SNI Containers' name="sni_container_refs">
            { containers.error ? <span className="text-danger">{containers.error}</span>:""}
              <SelectInput name="sni_container_refs" isLoading={containers.isLoading} isMulti items={containers.items} onChange={onSelectSNIContainers} />
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  A list of containers with alternative TLS secrets used for Server Name Indication (SNI).
                </span>
            </Form.ElementHorizontal>
          }


          {clientAuthenticationSelectItems.length > 0 &&
            <Form.ElementHorizontal label='Client Authentication Mode' name="client_authentication">
              <SelectInput name="client_authentication" items={clientAuthenticationSelectItems} onChange={onSelectClientAuthentication} />
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  The TLS client authentication mode.
                </span>
            </Form.ElementHorizontal>
          }

          {showCATLSContainer &&
            <Form.ElementHorizontal label='Client Authentication Container' name="client_ca_tls_container_ref">
              <SelectInput name="client_ca_tls_container_ref" isLoading={containers.isLoading}  items={containers.items} onChange={onSelectCATLSContainers}  />
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  The TLS client authentication certificate.
                </span>
            </Form.ElementHorizontal>
          }

          <Form.ElementHorizontal label='Tags' name="tags">
            <TagsInput name="tags" />
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
    </Modal>
   );
}
 
export default NewListener;