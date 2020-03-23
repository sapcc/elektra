import React, { useState, useEffect, useContext } from 'react';
import { Modal, Button } from 'react-bootstrap';
import useCommons from '../../../lib/hooks/useCommons'

const NewL7Policy = (props) => {
  const {searchParamsToString, queryStringSearchValues} = useCommons()

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
      const values = queryStringSearchValues
      const lbID = values.loadbalancerID
      props.history.replace(`/loadbalancers/${lbID}/show?${searchParamsToString(props)}`)
    }
  }

  console.log("RENDER new L7 Policy")

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
          <Modal.Title id="contained-modal-title-lg">New L7 Policy</Modal.Title>
        </Modal.Header>

        <Modal.Body>
          Body
        </Modal.Body>

    </Modal>
   );
}
 
export default NewL7Policy;