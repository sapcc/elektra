import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';

export default class EditShareNetworkForm extends React.Component {
  constructor(props){
  	super(props);

  	this.state = {show: this.props.shareNetwork!=null};
    this.close = this.close.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
  }

  componentWillReceiveProps(nextProps) {
    this.setState({show: nextProps.shareNetwork!=null})
  }

  validate(values) {
    return values.name && true
  }

  close(e){
    if(e) e.stopPropagation()
    this.setState({show: false})
    setTimeout(() => this.props.history.replace('/share-networks'),300)
  }

  onSubmit(values){
    return this.props.handleSubmit(values).then(() => this.close())
  }

  render(){
    return (
      <Modal show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">Edit Share Network</Modal.Title>
        </Modal.Header>

        <Form
          validate={this.validate}
          onValueChange={this.onValueChange}
          initialValues={this.props.shareNetwork}
          className='form form-horizontal'
          onSubmit={this.onSubmit}>

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
            <Button onClick={this.close}>Cancel</Button>
            <Form.SubmitButton label='Save'/>
          </Modal.Footer>

        </Form>
      </Modal>
    );
  }
}
