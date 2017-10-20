import PropTypes from 'prop-types';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'elektra-form';
import { Link } from 'react-router-dom';

const protocols = ['NFS','CIFS']

const EditShareForm = ({onHide, show, onSubmit}) => {
  return (
    <Modal show={show} onHide={onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">Edit Share</Modal.Title>
      </Modal.Header>

      <form onSubmit={onSubmit} className='form form-horizontal'>
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
          <Button onClick={onHide}>Cancel</Button>
          <Form.SubmitButton label='Save'/>
        </Modal.Footer>
      </form>
    </Modal>
  )
}

export default class EditShareFormWrapper extends React.Component {
  constructor(props){
  	super(props);
  	this.state = {show: this.props.share!=null};
    this.close = this.close.bind(this)
  }
  componentWillReceiveProps(nextProps) {
    this.setState({show: nextProps.share!=null})
  }

  close(e){
    if(e) e.preventDefault()
    this.setState({show: false})
    setTimeout(() => this.props.history.replace('/shares'), 300)
  }

  render(){
    return (
      <Form.Provider
        resetAfterSubmit={true}
        resetForm={!this.props.share}
        afterSubmitSuccess={this.close}
        validate={values => true}
        initialValues={this.props.share}
        show={this.state.show}
        onHide={this.close}
        {...this.props}>
        <EditShareForm/>
      </Form.Provider>
    )
  }
}
