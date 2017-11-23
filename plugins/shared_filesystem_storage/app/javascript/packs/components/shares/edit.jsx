import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';

export default class EditShareForm extends React.Component {
  constructor(props){
  	super(props);
  	this.state = {show: this.props.share!=null};
    this.close = this.close.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
  }

  componentDidMount() {
    this.props.loadShareTypesOnce()
  }
  
  componentWillReceiveProps(nextProps) {
    this.setState({show: nextProps.share!=null})
  }

  close(e){
    if(e) e.preventDefault()
    this.setState({show: false})
    setTimeout(() => this.props.history.replace('/shares'), 300)
  }

  onSubmit(values) {
    return this.props.handleSubmit(values).then(() => this.close());
  }

  render(){
    return (
      <Modal show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">Edit Share</Modal.Title>
        </Modal.Header>

        <Form
          onSubmit={this.onSubmit}
          className='form form-horizontal'
          validate={values => true}
          initialValues={this.props.share}>
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
    )
  }
}
