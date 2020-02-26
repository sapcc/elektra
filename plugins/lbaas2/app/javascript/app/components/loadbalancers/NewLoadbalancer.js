import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import CreatableSelect from 'react-select/creatable';


const NewLoadbalancer = (props) => {

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

  const validate = ({name,size,availability_zone,description,bootable,imageRef}) => {
    return name && size && availability_zone && description && (!bootable || imageRef) && true
  }

  const onSubmit = (values) =>{
    return false
  }

  const initialValues = {}

  const privateNetworks = {
    isLoading: true,
    error: null,
    items: []
  }

  /*
  * Tag editor
   */
  const components = {
    DropdownIndicator: null,
  };
  const createOption = (label) => {
    console.group('createOption');
    console.log(label);
    console.groupEnd();
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
      <Modal.Body>
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">New Load Balancer</Modal.Title>
        </Modal.Header>
        
        <Modal.Body>
          <p>The Load Balancer object defines the internal IP address under which all associated listeners can be reached. For external access a Floating IP can be attached to the Load Balancer.</p>
          <Form
            className='form form-horizontal'
            validate={validate}
            onSubmit={onSubmit}
            initialValues={initialValues}>
            <Form.Errors/>
            <Form.ElementHorizontal label='Name' name="name" required>
              <Form.Input elementType='input' type='text' name='name'/>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Description' name="description">
              <Form.Input elementType='input' type='text' name='description'/>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Private Network' required name="private_network">
              { privateNetworks.isLoading ?
                <span className='spinner'/>
                :
                privateNetworks.error ?
                  <span className='text-danger'>{privateNetworks.error}</span>
                  :
                  <Form.Input
                    elementType='select'
                    className="select required form-control"
                    name='private_network'>
                    <option></option>
                    {private_network.items.map((pn,index) =>
                      <option value={pn.name} key={index}>
                        {pn.name}
                      </option>
                    )}
                  </Form.Input>
              }
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                The network which provides the internal IP of the load balancer.
              </span>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='IP Address' name="ip_address">
              <Form.Input elementType='input' type='text' name='ip_address'/>
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                You can specify an IP from the private network if you like. Otherwise an IP will be allocated automatically.
              </span>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Tags' name="tags">
              {/* <Form.Input elementType='input' type='text' name='tags' className="js-node-input-tags" /> */}
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
                Start a new tag typing a string and hitting the Enter or Tab key. You can also copy and paste a string containing tags following this pattern: 'value1;value2...'
              </span>
            </Form.ElementHorizontal>
          </Form>

        </Modal.Body>        

        <Modal.Footer>  
          <Button onClick={close}>Cancel</Button>
          {/* <Form.SubmitButton label='Save'/> */}
        </Modal.Footer>
      </Modal.Body>
    </Modal>
   );
}
 
export default NewLoadbalancer;