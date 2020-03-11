import React, { useState, useEffect, useContext } from 'react';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import { ajaxHelper } from 'ajax_helper';
import { addNotice } from 'lib/flashes';
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'
import SelectInput from './SelectInput'
import TagsInput from './TagsInput'


const NewLoadbalancer = (props) => {
  const {createLoadbalancer, fetchSubnets} = useLoadbalancer()

  const [privateNetworks, setPrivateNetworks] = useState({
    isLoading: false,
    error: null,
    items: []
  })

  useEffect(() => {
    console.log('fetching private networks')
    setPrivateNetworks({...privateNetworks, isLoading:true})
    ajaxHelper.get(`/loadbalancers/private-networks`).then((response) => {
      setPrivateNetworks({...privateNetworks, isLoading:false, items: response.data.private_networks, error: null})
    })
    .catch( (error) => {      
      setPrivateNetworks({...privateNetworks, isLoading:false, error: errorMessage(error)})
    })
  }, []);

  const errorMessage = (error) => {
    if (error.response && error.response.data && error.response.data.errors && Object.keys(error.response.data.errors).length) {
      return error.response.data.errors
    } else {
      return error.message
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
      props.history.replace('/loadbalancers')
    }
  }

  /*
  * Form stuff
  */
  const [formErrors,setFormErrors] = useState(null)
  const [initialValues, setInitialValues] = useState({})

  const validate = ({name,description,vip_netowrk_id,vip_subnet_id,vip_address,tags}) => {
    return name && vip_netowrk_id && true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    return createLoadbalancer(values).then((response) => {
      addNotice(<React.Fragment>Loadbalancer <b>{response.data.name}</b>({response.data.id}) is being created.</React.Fragment>)
      close()
    }).catch(error => {
      setFormErrors(errorMessage(error))
    })
  }

  const [privateNetwork, setPrivateNetwork] = useState(null)
  const [subnets, setSubnets] = useState({ isLoading: false, error: null, items: [] })
  const [subnet, setSubnet] = useState(null)

  const onSelectPrivateNetworkChange = (props) => {
    if (props) {
      setPrivateNetwork(props)
      setSubnets({...subnets, isLoading: true, error: null})
      fetchSubnets(props.value)
      .then( (response) => {
        // new subnets loaded
        setSubnets({...subnets, isLoading: false, error: null, items: response})
        // reset selected subnet
        setSubnet(null)
      })
      .catch( (error) => {     
        setSubnets({...subnets, isLoading: false, error: errorMessage(error)})
      })
    }
  }

  const onSelectSubnetChange = (props) => {
    if (props) {
      setSubnet(props)
    }
  }

  const [showAdvanceNetworkSettings, setShowAdvanceNetworkSettings] =  useState(false)
  const handleAdvanceNetworkSettings = () => {
    setShowAdvanceNetworkSettings(!showAdvanceNetworkSettings)
  }

  console.log("RENDER new loadbalancer")
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
          <Modal.Title id="contained-modal-title-lg">New Load Balancer</Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={validate}
          onSubmit={onSubmit}
          initialValues={initialValues}>

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
              <SelectInput name="vip_netowrk_id" isLoading={privateNetworks.isLoading} items={privateNetworks.items} onChange={onSelectPrivateNetworkChange} value={privateNetwork}/>
              { privateNetworks.error ? <span className='text-danger'>{privateNetworks.error}</span>:""}
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                The network which provides the internal IP of the load balancer.
              </span>
            </Form.ElementHorizontal>

            <Form.ElementHorizontal>
              <span className="pull-right">
                <Button bsStyle="link" onClick={handleAdvanceNetworkSettings} >Toggle advanced network options</Button>
              </span>              
            </Form.ElementHorizontal>

            {showAdvanceNetworkSettings &&
              <div className="advanced-options">
                <h5>Advanced Network Options</h5>
                <p>These optional settings are for advanced usecases that require more control over the network configuration of the new loadbalancer.</p>
                <Form.ElementHorizontal label='Subnet' name="vip_subnet_id">
                  <SelectInput name="vip_subnet_id" isLoading={subnets.isLoading} items={subnets.items} onChange={onSelectSubnetChange} value={subnet} conditionalPlaceholderText="Please choose a network first." conditionalPlaceholderCondition={privateNetwork == null}/>
                  { privateNetworks.error ? <span className='text-danger'>{privateNetworks.error}</span>:""}
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    You can specify a subnet from which the fixed IP is chosen. If empty any subnet is selected.
                  </span>
                </Form.ElementHorizontal>

                <Form.ElementHorizontal label='IP Address' name="vip_address">
                  <Form.Input elementType='input' type='text' name='vip_address'/>
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    You can specify an IP from the subnet if you like. Otherwise an IP will be allocated automatically.
                  </span>
                </Form.ElementHorizontal>
              </div>
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
 
export default NewLoadbalancer;