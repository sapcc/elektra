import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import { Link } from 'react-router-dom';

const FormBody = ({values, availabilityZones}) =>
  <Modal.Body>
    <Form.Errors/>

    <Form.ElementHorizontal label='Name' name="name" required>
      <Form.Input elementType='input' type='text' name='name'/>
    </Form.ElementHorizontal>

    <Form.ElementHorizontal label='Description' name="description" required>
      <Form.Input elementType='textarea' className="text optional form-control" name="description"/>
    </Form.ElementHorizontal>

    <Form.ElementHorizontal label='Size in GB' name="size" required>
      <Form.Input elementType='input' type='number' name='size'/>
    </Form.ElementHorizontal>

    <Form.ElementHorizontal label='Availability Zone' required name="availability_zone">
      { availabilityZones.isFetching ?
        <span className='spinner'/>
        :
        availabilityZones.error ?
          <span className='text-danger'>{availabilityZones.error}</span>
          :
          <Form.Input
            elementType='select'
            className="select required form-control"
            name='availability_zone'>
            <option></option>
            {availabilityZones.items.map((az,index) =>
              <option value={az.zoneName} key={index}>
                {az.zoneName}
              </option>
            )}
          </Form.Input>
      }
    </Form.ElementHorizontal>
  </Modal.Body>

export default class NewVolumeForm extends React.Component {
  state = { show: true }

  componentDidMount() {
    this.loadDependencies(this.props)
  }

  componentWillReceiveProps(nextProps) {
    this.loadDependencies(nextProps)
  }

  loadDependencies = (props) => {
    props.loadAvailabilityZonesOnce()
  }


  validate = (values) => {
    return values.name && values.size && values.availability_zone && values.description && true
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
    return this.props.handleSubmit(values).then(() => this.close());
  }

  render(){
    const initialValues = {}

    return (
      <Modal
        show={this.state.show}
        onHide={this.close}
        bsSize="large"
        backdrop='static'
        onExited={this.restoreUrl}
        aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">New Volume</Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={this.validate}
          onSubmit={this.onSubmit}
          initialValues={initialValues}>

          <FormBody availabilityZones={this.props.availabilityZones}/>

          <Modal.Footer>
            <Button onClick={this.close}>Cancel</Button>
            <Form.SubmitButton label='Save'/>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
