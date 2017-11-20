import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';

export default class NewEntryForm extends React.Component {
  constructor(props){
  	super(props);
  	this.state = {show: true};
    this.close = this.close.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
  }

  validate(values) {
    return values.name && true
  }

  close(e){
    if(e) e.stopPropagation()
    this.setState({show: false})
    setTimeout(() => this.props.history.replace('/entries'),300)
  }

  onSubmit(values){
    // handleSubmit returns a promise object. So, we can call then on this object
    return this.props.handleSubmit(values).then(() => this.close());
  }

  render(){
    return (
      <Modal show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">New Entry</Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={this.validate}
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
