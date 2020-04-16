import React, { useState} from 'react';
import useCommons from '../../../lib/hooks/useCommons'
import { Modal, Button } from 'react-bootstrap';

const NewL7Rule = (props) => {
  const {searchParamsToString, queryStringSearchValues, matchParams, formErrorMessage} = useCommons()

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
        <Modal.Title id="contained-modal-title-lg">New L7 Rule</Modal.Title>
      </Modal.Header>

    </Modal>
   );
}
 
export default NewL7Rule;