import { Modal, Button } from 'react-bootstrap';

export default class AccountCreateModal extends React.Component {
  state = {
    show: true,
  };

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({show: false});
    setTimeout(() => this.props.history.replace('/'), 300);
  }

  render() {
    //TODO add form, allow to submit()
    //TODO: only allow creating accounts if there is Swift quota
    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Create New Keppel Account
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <p>TODO</p>
        </Modal.Body>

        <Modal.Footer>
          <Button bsStyle='primary' disabled={true}>Create</Button>
          <Button onClick={this.close}>Cancel</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
