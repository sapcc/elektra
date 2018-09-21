import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import { Link } from 'react-router-dom';

const FormBody = ({values}) =>
  <Modal.Body>
    <Form.Errors/>

    <Form.ElementHorizontal label='Server ID' name="server_id" required>
      <Form.Input elementType='input' type='text' name='server_id'/>
    </Form.ElementHorizontal>
  </Modal.Body>

export default class AttachVolumeForm extends React.Component {
  state = { show: true }

  componentDidMount() {
    if(!this.props.volume) {
      this.props.loadVolume().catch((loadError) => this.setState({loadError}))
    }
  }

  validate = (values) => {
    return values.server_id && true
  }

  close = (e) => {
    if(e) e.stopPropagation()
    this.setState({show: false})
  }

  restoreUrl = (e) => {
    if (!this.state.show)
      this.props.history.replace(`/volumes`)
  }

  onSubmit = (values) =>{
    return this.props.attachVolume(values).then(() => this.close());
  }

  render(){
    const initialValues = this.props.volume ? {
      name: this.props.volume.name
    } : {}

    return (
      <Modal
        show={this.state.show}
        onHide={this.close}
        bsSize="large"
        onExited={this.restoreUrl}
        aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Attach Volume <span className="info-text">{initialValues.name || this.props.id}</span>
          </Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={this.validate}
          onSubmit={this.onSubmit}
          initialValues={initialValues}>

          {this.props.volume ?
            <FormBody/>
            :
            <Modal.Body>
              <span className='spinner'></span>
              Loading...
            </Modal.Body>
          }

          <Modal.Footer>
            <Button onClick={this.close}>Cancel</Button>
            <Form.SubmitButton label='Attach'/>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
