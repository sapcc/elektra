import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';

export default class RBACPoliciesEditModal extends React.Component {
  state = {
    show: true,
  };

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({ ...this.state, show: false });
    setTimeout(() => this.props.history.replace('/accounts'), 300);
  }

  validate = (values) => {
    return true;
  };

  onSubmit = ({in_maintenance}) => {
    const newAccount = {
      ...this.props.account,
      in_maintenance: !this.props.account.in_maintenance,
    };
    return this.props.putAccount(newAccount).then(() => this.close());
  };

  render() {
    const { account, isAdmin } = this.props;
    if (!account || !isAdmin) {
      return null;
    }
    const { in_maintenance: inMaintenance } = account;

    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            {inMaintenance ? 'End maintenance for account' : 'Set account in maintenance'}: {account.name}
          </Modal.Title>
        </Modal.Header>

        <Form
            className='form form-horizontal'
            validate={this.validate}
            onSubmit={this.onSubmit}
            initialValues={{}}>

          <Modal.Body>
            <p>
              This account {inMaintenance ? 'has been' : 'can be'} set <strong>in maintenance</strong> to prevent the pushing of new images into it. The account can only be deleted while it is in maintenance.
            </p>
          </Modal.Body>

          <Modal.Footer>
            <Form.SubmitButton label={inMaintenance ? 'End maintenance' : 'Set in maintenance'} />
            <Button onClick={this.close}>Cancel</Button>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }

}
