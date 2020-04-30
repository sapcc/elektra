import React, { useState,useEffect} from 'react';
import useCommons from '../../../lib/hooks/useCommons'
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import useListener from '../../../lib/hooks/useListener'
import SelectInput from '../shared/SelectInput'
import TagsInput from '../shared/TagsInput'

const NewListener = (props) => {
  const {searchParamsToString, queryStringSearchValues, matchParams, formErrorMessage} = useCommons()
  const {protocolTypes, fetchPools} = useListener()
  const [pools, setPools] = useState({
    isLoading: false,
    error: null,
    items: []
  })

  useEffect(() => {
    console.log('fetching pools')
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    setPools({...pools, isLoading:true})
    fetchPools(lbID).then((data) => {
      setPools({...pools, isLoading:false, items: data.pools, error: null})
    })
    .catch( (error) => {      
      setPools({...pools, isLoading:false, error: error})
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
  const [pool, setPool] = useState(null)

  const validate = ({name,description,protocol_port,protocol,default_pool_id,connection_limit,insert_headers,tags}) => {
    return name && protocol_port && protocol && true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    // save the entered values in case of error
    setInitialValues(values)
    
  }

  const onSelectProtocolType = () => {}
  const onSelectPoolChange = () => {}

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
            <Form.ElementHorizontal label='Protocol Port' name="protocol_port">
              <Form.Input elementType='input' type='number' min="1" max="65535" name='protocol_port'/>
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                The port under which the load balancer can be called. A port number between 1 and 65535.
              </span>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Protocol' name="protocol">
            <SelectInput name="type" items={protocolTypes()} onChange={onSelectProtocolType} />
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                The protocol which can be used to access the load balancer port.
              </span>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Default Pool' name="default_pool_id">
            <SelectInput name="default_pool_id" isLoading={pools.isLoading} items={pools.items} onChange={onSelectPoolChange} value={pool}/>
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                The pool to which all traffic will be routed if no L7 Policy defines a different pool.
              </span>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Connection Limit' name="connection_limit">
              <Form.Input elementType='input' type='number' min="1" name='connection_limit'/>
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                The number of parallel connections allowed to access the load balancer. Value -1 means infinite connections are allowed.
              </span>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Tags' name="tags">
              <TagsInput name="tags" />
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                Start a new tag typing a string and hitting the Enter or Tab key.
              </span>
            </Form.ElementHorizontal>
        </Modal.Body>

      </Form>
    </Modal>
   );
}
 
export default NewListener;