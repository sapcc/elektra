import { useContext } from 'react';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';

const initialValues = { name: '', role: 'primary', peer: '' };

const roleInfoTexts = {
  'primary': "You can push images into this account, and accounts in other regions can replicate from this account.",
  'replica': "This account replicates images from a primary account in a different region with the same name. You cannot push images into this account directly. Images are replicated on first use, when a client first tries to pull them.",
};

const FormBody = ({ values, peerHostNames }) => {
  const accountName  = values.name || '';
  const roleInfoText = roleInfoTexts[values.role || ''];

  return (
    <Modal.Body>
      <Form.Errors/>

      <Form.ElementHorizontal label='Name' name='name' required>
        <Form.Input elementType='input' type='text' name='name' />
      </Form.ElementHorizontal>

      <Form.ElementHorizontal label='Backing storage' name='backing_storage'>
        { accountName ? (
          <p className='form-control-static'>
            Swift container <strong>keppel-{accountName}</strong><br/>
            <span className='text-muted'>The container will be created if it does not exist yet. Please ensure that you have sufficient object storage quota.</span>
          </p>
        ) : (
          <p className='form-control-static text-muted'>Depends on name</p>
        )}
      </Form.ElementHorizontal>

      <Form.ElementHorizontal label='Role' name='role' required>
        <Form.Input elementType='select' name='role'>
          <option value='primary'>Primary account</option>
          <option value='replica'>Replica</option>
        </Form.Input>
        {roleInfoText && <p className='form-control-static'>{roleInfoText}</p>}
      </Form.ElementHorizontal>

      {values.role == "replica" && (
        <Form.ElementHorizontal label='Upstream registry' name='peer' required>
          <Form.Input elementType='select' name='peer'>
            <option></option>
            {peerHostNames.map(hostname => <option key={hostname} value={hostname}>{hostname}</option>)}
          </Form.Input>
          {values.peer && values.name && (
            <p className='form-control-static'>
              This account will replicate from <strong>{values.peer}/{values.name}</strong>.
            </p>
          )}
        </Form.ElementHorizontal>
      )}

      <Form.ElementHorizontal label='Advanced' name='advanced'>
        <p className='form-control-static text-muted'>
          You can set up access policies and validation rules once the account has been created.
        </p>
      </Form.ElementHorizontal>

    </Modal.Body>
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

  validate = ({name, role, peer}) => {
    if (role == 'replica' && !peer) {
      return false;
    }
    return name && true;
  };

  onSubmit = ({name, role, peer}) => {
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
    if (role == 'replica') {
      newAccount.replication = { strategy: 'on_first_use', upstream: peer };
    }

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

          <FormBody peerHostNames={this.props.peerHostNames} />

          <Modal.Footer>
            <Form.SubmitButton label='Create' />
            <Button onClick={this.close}>Cancel</Button>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
