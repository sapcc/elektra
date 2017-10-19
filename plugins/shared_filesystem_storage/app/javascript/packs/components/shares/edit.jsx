import PropTypes from 'prop-types';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'elektra-form';
import { Link } from 'react-router-dom';

const protocols = ['NFS','CIFS']

const EditShareForm = ({
  onHide,
  show,
  values,
  onSubmit,
  resetForm
}) => {
  let hide = () => {
    resetForm()
    onHide()
  }

  let submit = (e) => {
    onSubmit(e, {onSuccess: hide})
  }

  return (
    <Modal show={show} onHide={hide} bsSize="large" aria-labelledby="contained-modal-title-lg">
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">Edit Share</Modal.Title>
      </Modal.Header>

      <form onSubmit={submit} className='form form-horizontal'>
        <Modal.Body>
          <Form.Errors/>

          <Form.ElementHorizontal label='Name' name="name">
            <Form.Input elementType='input' type='text' name='name'/>
          </Form.ElementHorizontal>

          <Form.ElementHorizontal label='Description' name="description">
            <Form.Input elementType='textarea' className="text optional form-control" name="description"/>
          </Form.ElementHorizontal>

        </Modal.Body>
        <Modal.Footer>
          <Button onClick={hide}>Cancel</Button>
          <Form.SubmitButton label='Save'/>
        </Modal.Footer>
      </form>
    </Modal>
  )
}

export default ({share, ...otherProps}) => {
  return (
    <Form.Provider
      validate={values => true}
      initialValues={share}
      show={share!=null}
      {...otherProps}>
      <EditShareForm/>
    </Form.Provider>
  );
}
