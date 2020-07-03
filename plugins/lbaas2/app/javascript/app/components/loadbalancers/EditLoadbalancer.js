import React, { useState, useEffect } from 'react';
import { Modal, Button } from 'react-bootstrap';
import useCommons from '../../../lib/hooks/useCommons'
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'
import ErrorPage from '../ErrorPage';
import { Form } from 'lib/elektra-form';
import { matchPath } from 'react-router-dom'
import SelectInput from '../shared/SelectInput'
import TagsInput from '../shared/TagsInput'
import { addNotice } from 'lib/flashes';

const EditLoadbalancer = (props) => {
  const {matchParams, searchParamsToString, formErrorMessage, errorMessage} = useCommons()
  const {fetchLoadbalancer, fetchPrivateNetworks, updateLoadbalancer} = useLoadbalancer()
  const [loadbalancer, setLoadbalancer] = useState({
    isLoading: false,
    error: null,
    item: null
  })
  const [privateNetworks, setPrivateNetworks] = useState({
    isLoading: false,
    error: null,
    items: []
  })
  const [privateNetwork, setPrivateNetwork] = useState(null)
  const [loadbalancerID, setLoadbalancerID] = useState(null)

  useEffect(() => {
    console.log('fetching loadbalancer to edit')
    loadLoadbalancer()
  }, []);

  const loadLoadbalancer = () => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    setLoadbalancerID(lbID)
    // fetch the loadbalancer to edit
    setLoadbalancer({...loadbalancer, isLoading:true})
    fetchLoadbalancer(lbID).then((data) => {
      loadPrivateNetworks(data.loadbalancer.vip_network_id)
      setLoadbalancer({...loadbalancer, isLoading:false, item: data.loadbalancer, error: null})
    })
    .catch( (error) => {      
      setLoadbalancer({...loadbalancer, isLoading:false, error: error})
    })
  }

  const loadPrivateNetworks = (pn) => {
    console.log('fetching private networks')
    setPrivateNetworks({...privateNetworks, isLoading:true})
    fetchPrivateNetworks().then((data) => {      
      const private_networks = data.private_networks
      const result = private_networks.find(i=>i.value == pn.trim());
      setPrivateNetwork(result)
      setPrivateNetworks({...privateNetworks, isLoading:false, items: data.private_networks, error: null})
    })
    .catch( (error) => {      
      setPrivateNetworks({...privateNetworks, isLoading:false, error: errorMessage(error)})
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
      const isRequestFromDetails = matchPath(
        props.location.pathname, 
        '/loadbalancers/:loadbalancerID/show/edit'
      ); 
      if (isRequestFromDetails && isRequestFromDetails.isExact) {
        props.history.replace(`/loadbalancers/${loadbalancerID}/show?${searchParamsToString(props)}`)
      } else {
        props.history.replace('/loadbalancers')
      }
    }
  }

  /**
   * Form stuff
   */
  const [formErrors,setFormErrors] = useState(null)

  const validate = ({name,description,tags}) => {
    return name && true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    
    return updateLoadbalancer(loadbalancerID, values).then((response) => {
      addNotice(<React.Fragment>Load Balancer <b>{response.data.name}</b> ({response.data.id}) is being updated.</React.Fragment>)
      close()
    }).catch(error => {
      setFormErrors(formErrorMessage(error))
    })

  }

  console.log("RENDER edit loadbalancer")
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
        <Modal.Title id="contained-modal-title-lg">Edit Load Balancer</Modal.Title>
      </Modal.Header>

      {loadbalancer.error ?
        <Modal.Body>
          <ErrorPage headTitle="Edit Load Balancer" error={loadbalancer.error} onReload={loadLoadbalancer}/>
        </Modal.Body>
      :
        <React.Fragment>
          {loadbalancer.isLoading ? 
              <Modal.Body>
                <span className='spinner'/>
              </Modal.Body>
            :
            <Form
              className='form form-horizontal'
              validate={validate}
              onSubmit={onSubmit}
              initialValues={loadbalancer.item}
              resetForm={false}>

            <Modal.Body>
              <p>The Load Balancer object defines the internal IP address under which all associated listeners can be reached. For external access a Floating IP can be attached to the Load Balancer.</p>
              <Form.Errors errors={formErrors}/>
              <Form.ElementHorizontal label='Name' name="name" required>
                <Form.Input elementType='input' type='text' name='name'/>
              </Form.ElementHorizontal>
              <Form.ElementHorizontal label='Description' name="description">
                <Form.Input elementType='input' type='text' name='description'/>
              </Form.ElementHorizontal>
              <Form.ElementHorizontal label='Private Network' required name="vip_network_id">
                <SelectInput name="vip_network_id" isLoading={privateNetworks.isLoading} items={privateNetworks.items} value={privateNetwork} isDisabled={true}/>
                { privateNetworks.error ? <span className='text-danger'>{privateNetworks.error}</span>:""}
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  The network which provides the internal IP of the load balancer.
                </span>
              </Form.ElementHorizontal>
              <Form.ElementHorizontal>
                <span className="pull-right">
                  <span className="info-text" >No advanced network options available</span>
                </span>              
              </Form.ElementHorizontal>
              <Form.ElementHorizontal label='Tags' name="tags">
                <TagsInput name="tags" initValue={loadbalancer.item && loadbalancer.item.tags}/>
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
 
export default EditLoadbalancer;