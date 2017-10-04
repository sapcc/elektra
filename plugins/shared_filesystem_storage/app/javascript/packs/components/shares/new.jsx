import { Modal, Button } from 'react-bootstrap';

export default ({show, onHide}) =>
  <Modal show={show} onHide={onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
    <Modal.Header closeButton>
      <Modal.Title id="contained-modal-title-lg">New Share</Modal.Title>
    </Modal.Header>
    <Modal.Body>
      <h4>New Share</h4>
    </Modal.Body>
    <Modal.Footer>
      <Button onClick={onHide}>Close</Button>
    </Modal.Footer>
  </Modal>
