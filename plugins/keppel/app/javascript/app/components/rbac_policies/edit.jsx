import { Modal, Button } from 'react-bootstrap';

export default class RBACPoliciesEditModal extends React.Component {
  state = {
    show: true,
  };

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({show: false});
    setTimeout(() => this.props.history.replace('/'), 300);
  }

  render() {
    const { name: accountName, rbac_policies: policies } = this.props.account || {};

    //TODO add form, if (props.isAdmin) { make editable }
    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Access policies for account: {accountName}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          {this.props.isFetching ? (
            <p><span className='spinner' /> Loading...</p>
          ) : (
            <pre>{JSON.stringify(policies, null, 2)}</pre>
          )}
        </Modal.Body>

        <Modal.Footer>
          <Button bsStyle='primary' disabled={true}>Save</Button>
          <Button onClick={this.close}>Cancel</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
