import React, { useState, useEffect } from 'react';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import CreatableSelect from 'react-select/creatable';
import { ajaxHelper } from 'ajax_helper';
import { useDispatch } from '../StateProvider'


const NewLoadbalancer = (props) => {
  const dispatch = useDispatch()
  
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
  const validate = ({name,description,vip_subnet_id,vip_address,tags}) => {
    return name && vip_subnet_id && true
  }

  const onSubmit = (values) => {    
    return new Promise((handleSuccess,handleErrors) => {
      // collect the tags extra
      const tags = tagEditorValue.map( (value, index) => value.value )
      // copy tags to the values of the form
      values = {...values, tags: tags}    
      setFormErrors(null)
      ajaxHelper.post('/loadbalancers/', { loadbalancer: values }).then((response) => {
        dispatch(receiveVolume(response.data))
        handleSuccess()
      }).catch(error => {
        setFormErrors(errorMessage(error))
        handleErrors(error)
      })
    }).then(() => close())
  }

  const initialValues = {}

  /*
  * Tag editor
   */
  const components = {
    DropdownIndicator: null,
  };
  const createOption = (label) => {
    return {
      label,
      value: label,
    }
  };
  const [tagEditorInputValue, setTagEditorInputValue] = useState("")
  const [tagEditorValue, setTagEditorValue] = useState([])
  const onTagEditorChange = (value, actionMeta) => {
    setTagEditorValue(value || [])
  };
  const onTagEditorInputChange = (inputValue) => {  
    setTagEditorInputValue(inputValue)
  };
  const onTagEditorKeyDown = (event) => {
    if (!tagEditorInputValue) return;
    switch (event.key) {
      case 'Enter':
      case 'Tab':
        setTagEditorValue([...tagEditorValue, createOption(tagEditorInputValue)])
        setTagEditorInputValue("")        
        event.preventDefault();
    }
  };

  console.log("RENDER new loadbalancer")
  return ( 
    <Modal
      show={show}
      onHide={close}
      bsSize="large"
      backdrop='static'
      onExited={restoreUrl}
      aria-labelledby="contained-modal-title-lg">
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
            <Form.ElementHorizontal label='Private Network' required name="vip_subnet_id">
              { privateNetworks.isLoading ?
                <span className='spinner'/>
                :
                privateNetworks.error ?
                  <span className='text-danger'>{privateNetworks.error}</span>
                  :
                  <React.Fragment>
                    <Form.Input
                      elementType='select'
                      className="select required form-control"
                      name='vip_subnet_id'>
                      <option></option>
                      {privateNetworks.items.map((pn,index) =>
                        pn.subnet[0] &&
                          <option value={pn.subnet[0].id} key={index}>
                            {pn.name} ({pn.subnet[0].cidr})
                          </option>                        
                      )}
                    </Form.Input>
                  </React.Fragment>
              }
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                The network which provides the internal IP of the load balancer.
              </span>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='IP Address' name="vip_address">
              <Form.Input elementType='input' type='text' name='vip_address'/>
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                You can specify an IP from the private network if you like. Otherwise an IP will be allocated automatically.
              </span>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Tags' name="tags">
              <CreatableSelect
                components={components}
                inputValue={tagEditorInputValue}
                isClearable
                isMulti
                menuIsOpen={false}
                onChange={onTagEditorChange}
                onInputChange={onTagEditorInputChange}
                onKeyDown={onTagEditorKeyDown}
                placeholder=""
                value={tagEditorValue}
              />
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