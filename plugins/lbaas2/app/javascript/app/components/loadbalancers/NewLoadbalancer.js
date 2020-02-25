import React, { useState, useEffect } from 'react';
import { Modal, Button } from 'react-bootstrap';

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
        <Modal.Footer>  
          <Button onClick={close}>Cancel</Button>
          {/* <Form.SubmitButton label='Save'/> */}
        </Modal.Footer>
      </Modal.Body>
    </Modal>
   );
}
 
export default NewLoadbalancer;