import React, { useState, useEffect } from 'react';
import { Modal, Button } from 'react-bootstrap';
import { matchPath } from 'react-router-dom'
import useCommons from '../../../lib/hooks/useCommons'
import { Form } from 'lib/elektra-form';
import useListener from '../../../lib/hooks/useListener'
import SelectInput from '../shared/SelectInput'
import ErrorPage from '../ErrorPage';
import TagsInput from '../shared/TagsInput'

const EditListener = (props) => {
  const {matchParams, searchParamsToString, formErrorMessage, errorMessage, fetchPoolsForSelect } = useCommons()
  const {fetchListener,protocolTypes} = useListener()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [listenerID, setListenerID] = useState(null)
  const [protocolType, setProtocolType] = useState(null)
  const [defaultPoolID, setDefaultPoolID] = useState(null)
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

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const ltID = params.listenerID
    setLoadbalancerID(lbID)
    setListenerID(ltID)
    loadListener(lbID, ltID)
  }, []);

  const loadListener = (lbID, ltID) => {
    console.log('fetching listener to edit')
    // fetch the listener to edit
    setListener({...listener, isLoading:true})
    fetchListener(lbID, ltID).then((data) => {
      const protocol = data.listener.protocol || ""
      const selectedProtocol = protocolTypes().find(i=>i.value == protocol.trim());
      setProtocolType(selectedProtocol)
      loadPools(lbID, data.listener.default_pool_id)
      setListener({...listener, isLoading:false, item: data.listener, error: null})
    })
    .catch( (error) => {      
      setListener({...listener, isLoading:false, error: error})
    })
  }

  const loadPools = (lbID, defaultPoolID) => {
    setPools({...pools, isLoading:true})
    fetchPoolsForSelect(lbID).then((data) => {
      const pools = data.pools
      const result = pools.find(i=>i.value == defaultPoolID.trim());
      setDefaultPoolID(result)
      setPools({...pools, isLoading:false, items: data.pools, error: null})
    })
    .catch( (error) => {      
      setPools({...pools, isLoading:false, error: error})
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

  const [formErrors,setFormErrors] = useState(null)

  const validate = ({}) => {
    return true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    
    // return updateLoadbalancer(loadbalancerID, values).then((response) => {
    //   addNotice(<React.Fragment>Load Balancer <b>{response.data.name}</b> ({response.data.id}) is being updated.</React.Fragment>)
    //   close()
    // }).catch(error => {
    //   setFormErrors(formErrorMessage(error))
    // })
  }

  const onSelectPoolChange = (props) => {}

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
                    <SelectInput name="default_pool_id" isLoading={pools.isLoading} items={pools.items} onChange={onSelectPoolChange} value={defaultPoolID}/>
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