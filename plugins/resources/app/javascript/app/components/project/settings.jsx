import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import { Link } from 'react-router-dom';

export default class ProjectSettingsModal extends React.Component {
  state = { show: true }

  validate = (values) => {
    return true;
  }

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({show: false});
    setTimeout(() => this.props.history.replace('/'), 300);
  }

  handleSubmit = (values) => {
    const oldHasBursting = this.props.metadata.bursting.enabled;
    const newHasBursting = values.has_bursting === 'yes';
    if (oldHasBursting == newHasBursting) {
      this.close();
    }

    return this.props.setProjectHasBursting({
      domainID:    this.props.domainID,
      projectID:   this.props.projectID,
      hasBursting: newHasBursting,
    }).then(() => this.close());
  }

  render() {
    const initialValues = {
      has_bursting: this.props.metadata.bursting.enabled ? 'yes' : 'no',
    };

    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Project Settings
          </Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={this.validate}
          onSubmit={this.handleSubmit}
          initialValues={initialValues}>

          <Modal.Body>
            <Form.Errors/>

            <Form.ElementHorizontal label='Bursting' name='has_bursting'>
              <Form.Input elementType='select' name='has_bursting'>
                <option value='no'>Disabled</option>
                <option value='yes'>Enabled</option>
              </Form.Input>
            </Form.ElementHorizontal>

            <div className='form-group row'>
              <div className='col-sm-8 col-sm-offset-4'>
                Quota bursting allows overshooting usage of a resource quota. See
                {' '}
                <a href={`${this.props.docsUrl}docs/quota/#quota-bursting`}>documentation</a>
                {' '}
                for details.
              </div>
            </div>
          </Modal.Body>

          <Modal.Footer>
            <Button onClick={this.close}>Cancel</Button>
            <Form.SubmitButton label='Save'/>
          </Modal.Footer>

        </Form>
      </Modal>
    );
  }
}
