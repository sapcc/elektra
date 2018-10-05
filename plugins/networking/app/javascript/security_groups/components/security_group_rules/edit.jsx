import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import { Link } from 'react-router-dom';

const FormBody = ({values}) =>
  <Modal.Body>
    <Form.Errors/>

    <Form.ElementHorizontal label='Name' name="name" required>
      <Form.Input elementType='input' type='text' name='name'/>
    </Form.ElementHorizontal>

    <Form.ElementHorizontal label='Description' name="description">
      <Form.Input elementType='textarea' className="text optional form-control" name="description"/>
    </Form.ElementHorizontal>
  </Modal.Body>

export default class EditSecurityGroupForm extends React.Component {
  state = { show: true }

  componentDidMount() {
    if(!this.props.securityGroup) {
      this.props.loadSecurityGroup().catch((loadError) => this.setState({loadError}))
    }
  }

  validate = (values) => {
    return values.name && true
  }

  close = (e) => {
    if(e) e.stopPropagation()
    this.setState({show: false})
  }

  restoreUrl = (e) => {
    if (!this.state.show)
      this.props.history.replace(`/`)
  }

  onSubmit = (values) =>{
    return this.props.handleSubmit(values).then(() => this.close());
  }

  render(){
    const initialValues = this.props.securityGroup ? {
      name: this.props.securityGroup.name,
      description: this.props.securityGroup.description
    } : {}

    return (
      <Modal
        show={this.state.show}
        onHide={this.close}
        bsSize="large"
        backdrop='static'
        onExited={this.restoreUrl}
        aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">Edit Security Group</Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={this.validate}
          onSubmit={this.onSubmit}
          initialValues={initialValues}>

          {this.props.securityGroup ?
            <FormBody/>
            :
            <Modal.Body>
              <span className='spinner'></span>
              Loading...
            </Modal.Body>
          }

          <Modal.Footer>
            <Button onClick={this.close}>Cancel</Button>
            <Form.SubmitButton label='Save'/>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
