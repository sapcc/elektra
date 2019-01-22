import { Modal, Button } from 'react-bootstrap';

import { byUIString, t } from '../../utils';

export default class ProjectEditModal extends React.Component {
  state = { show: true }

  validate = (values) => {
    return false;
  }

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({show: false});
    setTimeout(() => this.props.history.replace('/'), 300);
  }

  handleSubmit = (values) => {
    this.close();
  }

  render() {
    const { serviceType, category } = this.props.match;

    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Edit Project Quota: {t(category)}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <p>TODO</p>
        </Modal.Body>
      </Modal>
    );
  }
}
