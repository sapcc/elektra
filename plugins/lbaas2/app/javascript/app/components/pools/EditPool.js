import React, { useState, useEffect } from 'react';
import useCommons from '../../../lib/hooks/useCommons'
import { Modal, Button } from 'react-bootstrap';
import usePool from '../../../lib/hooks/usePool'
import ErrorPage from '../ErrorPage';
import { Form } from 'lib/elektra-form';
import SelectInput from '../shared/SelectInput'
import HelpPopover from '../shared/HelpPopover'
import { value } from 'numeral';

const EditPool = (props) => {
  const {matchParams, searchParamsToString, formErrorMessage, fetchPoolsForSelect } = useCommons()
  const {lbAlgorithmTypes,poolPersistenceTypes, protocolListenerPoolCombinations, poolProtocolListenerCombinations, fetchPool, helpBlockTextSessionPersistences} = usePool()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [poolID, setPoolID] = useState(null)

  const [lbAlgorithm, setLbAlgorithm] = useState(null)
  const [protocol, setProtocol] = useState(null)
  const [sessionPersistenceType, setSessionPersistenceType] = useState(null)

  const [pool, setPool] = useState({
    isLoading: false,
    error: null,
    item: null
  })

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const plID = params.poolID
    setLoadbalancerID(lbID)
    setPoolID(plID)
  }, []);

  useEffect(() => {
    if(poolID) {
      loadPool()
    }
  }, [poolID]);

  const loadPool = () => {
    console.log('fetching pool to edit')

    setPool({...pool, isLoading:true, error: null})
    fetchPool(loadbalancerID, poolID).then((data) => {
      setSelectedLbAlgorithm(data.pool.lb_algorithm)
      setSelectedProtocol(data.pool.protocol)
      setSelectedSessionPersistenceType(data.pool.session_persistence)
      setPool({...pool, isLoading:false, item: data.pool, error: null})
    })
    .catch( (error) => {      
      setPool({...pool, isLoading:false, error: error})
    })
  }

  const setSelectedLbAlgorithm = (selectedLbAlgorithm) => {
    const selectedOption = lbAlgorithmTypes().find(i=>i.value == (selectedLbAlgorithm || "").trim());
    setLbAlgorithm(selectedOption)
  }

  const setSelectedProtocol = (selectedProtocol) => {
    const selectedOption = protocolListenerPoolCombinations().find(i=>i.value == (selectedProtocol || "").trim());
    setProtocol(selectedOption)
  }

  const setSelectedSessionPersistenceType = (selectedPersistenceType) => {
    if(selectedPersistenceType && selectedPersistenceType.type) {
      const selectedOption = poolPersistenceTypes().find(i=>i.value == (selectedPersistenceType.type || "").trim());
      setSessionPersistenceType(selectedOption)
    }
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
  const [protocols, setProtocols ] = useState(protocolListenerPoolCombinations())
  const [showCookieName, setShowCookieName] = useState(false)

  const validate = ({name,description,lb_algorithm, session_persistence_type,session_persistence_cookie_name,listener_id,tls_enabled,tls_container_ref,ca_tls_container_ref,tags}) => {

    console.group("VALIDATE")
    console.log(name, "-", lb_algorithm)
    console.groupEnd()

    return name && lb_algorithm && true
  }

  const onSubmit = (values) => {
    console.group("ONSUBMIT")
    console.log(values)
    console.groupEnd()

    const newValues = {... values}
    if(newValues.session_persistence_type || newValues.session_persistence_cookie_name) {
      // the session has been changed and the Json blob should be deleted and new attributes has been saved in
      // session_persistence_type and/or session_persistence_cookie_name. Rails will be build the new JSON
    } else {
      if(newValues.session_persistence && newValues.session_persistence.type) {
        newValues.session_persistence_type = newValues.session_persistence.type        
      }
      if(newValues.session_persistence && newValues.session_persistence.cookie_name) {
        newValues.session_persistence_cookie_name = newValues.session_persistence.cookie_name        
      }
    }

    console.group("ONSUBMIT new")
    console.log(newValues)
    console.groupEnd()
  }

  const onLbAlgorithmChange = (option) => { setLbAlgorithm(option)}
  const onPoolPersistenceTypeChanged = (option) => { 
    setSessionPersistenceType(option) 
    setShowCookieName(option && option.value == "APP_COOKIE")
  }


  console.log("RENDER edit pool")
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
      <Modal.Title id="contained-modal-title-lg">Edit Pool</Modal.Title>
    </Modal.Header>

    {pool.error ?
        <Modal.Body>
          <ErrorPage headTitle="Edit Pool" error={pool.error} onReload={loadPool}/>
        </Modal.Body>
      :      
      <React.Fragment>
        {pool.isLoading ? 
          <Modal.Body>
            <span className='spinner'/>
          </Modal.Body>
        :
          <Form
            className='form form-horizontal'
            validate={validate}
            onSubmit={onSubmit}
            initialValues={pool.item}
            resetForm={false}>

            <Modal.Body>
              <p>Object representing the grouping of members to which the listener forwards client requests. Note that a pool is associated with only one listener, but a listener might refer to several pools (and switch between them using layer 7 policies).</p>
              <Form.Errors errors={formErrors}/>

              <Form.ElementHorizontal label='Name' name="name" required>
                <Form.Input elementType='input' type='text' name='name'/>
              </Form.ElementHorizontal>

              <Form.ElementHorizontal label='Description' name="description">
                <Form.Input elementType='input' type='text' name='description'/>
              </Form.ElementHorizontal>

              <Form.ElementHorizontal label='Lb Algorithm' name="lb_algorithm" required>
                <SelectInput name="lb_algorithm" items={lbAlgorithmTypes()} onChange={onLbAlgorithmChange} value={lbAlgorithm}/>
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  The method used for lbaas between members.
                </span>
              </Form.ElementHorizontal>

              <Form.ElementHorizontal label='Protocol' name="protocol" required>
                <SelectInput name="protocol" items={protocols} value={protocol} isDisabled={true}/>
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  The protocol used for routing the traffic to the members.
                </span>
              </Form.ElementHorizontal>

              <Form.ElementHorizontal label='Session Persistence Type' name="session_persistence_type">
                <SelectInput name="session_persistence_type" isClearable items={poolPersistenceTypes()} onChange={onPoolPersistenceTypeChanged} value={sessionPersistenceType}/>
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  <span className="help-block-text">Defines the method used for session stickiness. Traffic for a client will be send always to the same member after the session is established.</span>
                  <HelpPopover text={helpBlockTextSessionPersistences()} />
                </span>
              </Form.ElementHorizontal>

              {showCookieName &&
                <div className="advanced-options">
                  <Form.ElementHorizontal label='Cookie Name' name="session_persistence_cookie_name" required>
                    <Form.Input elementType='input' type='text' name='session_persistence_cookie_name' />
                    <span className="help-block">
                      <i className="fa fa-info-circle"></i>
                      The name of the HTTP cookie defined by your application. The cookie value will be used for session stickiness.
                    </span>
                  </Form.ElementHorizontal>
                </div>
              }

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
 
export default EditPool;