import { useContext } from 'react';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';

const initialValues = { name: '' };

const BackingStoreInfo = (props) => {
  const context = useContext(Form.Context);
  const accountName = context.formValues.name || '';
  if (!accountName) {
    return <p className='form-control-static text-muted'>Depends on name</p>;
  }

  const containerName = `keppel-${accountName}`;
  return (
    <p className='form-control-static'>
      Swift container <strong>{containerName}</strong><br/>
      <span className='text-muted'>The container will be created if it does not exist yet. Please ensure that you have sufficient object storage quota.</span>
    </p>
  );
};


export default class AccountCreateModal extends React.Component {
  state = {
    show: true,
  };

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({show: false});
    setTimeout(() => this.props.history.replace('/accounts'), 300);
  };

  validate = ({name}) => {
    return name && true;
  };

  onSubmit = ({name}) => {
    const invalidName = reason => Promise.reject({ errors: { name: reason } });
    if (/[^a-z0-9-]/.test(name)) {
      return invalidName("may only contain lowercase letters, digits and dashes");
    }
    if (name.length > 48) {
      return invalidName("must not be longer than 48 chars");
    }
    if (this.props.existingAccountNames.includes(name)) {
      return invalidName("is already in use");
    }

    const newAccount = { name, auth_tenant_id: this.props.projectID };
    return this.props.putAccount(newAccount).then(() => this.close());
  };

  render() {
    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Create New Keppel Account
          </Modal.Title>
        </Modal.Header>

        <Form
            className='form form-horizontal'
            validate={this.validate}
            onSubmit={this.onSubmit}
            initialValues={initialValues}>
          <Modal.Body>
            <Form.Errors/>

            <Form.ElementHorizontal label='Name' name='name' required>
              <Form.Input elementType='input' type='text' name='name' />
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Backing storage' name='backing_storage'>
              <BackingStoreInfo/>
            </Form.ElementHorizontal>
          </Modal.Body>

          <Modal.Footer>
            <Form.SubmitButton label='Create' />
            <Button onClick={this.close}>Cancel</Button>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
