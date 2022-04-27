import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import { Link } from 'react-router-dom';
import * as constants from '../../constants';

const FormBody = ({values,volume,availabilityZones}) =>
  <Modal.Body>
    <Form.Errors/>

    <Form.ElementHorizontal label='Source Volume' name="source_volid">
      <p className='form-control-static'>
        {volume ?
          <React.Fragment>
            {volume.name}
            <br/>
            <span className='info-text'>ID: {volume.id}</span>
          </React.Fragment>
          :
          volume.id
        }
      </p>
    </Form.ElementHorizontal>

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


export default class ResetVolumeStatusForm extends React.Component {
  state = { show: true }

  componentDidMount() {
    if(!this.props.volume) {
      this.props.loadVolume().catch((loadError) => this.setState({loadError}))
    }
    this.loadDependencies(this.props)
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    this.loadDependencies(nextProps)
  }

  loadDependencies = (props) => {
    props.loadAvailabilityZonesOnce()
  }

  validate = (values) => {
    return values.name && values.size && values.availability_zone && values.description && values.source_volid && true
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
    const {volume, availabilityZones, id} = this.props
    const initialValues = volume ? {
      source_volid: volume.id,
      name: `clone-${volume.name}`,
      description: `Clone of the volume ${volume.name} (${volume.id})`,
      availability_zone: volume.availability_zone,
      size: volume.size
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
            Clone Volume <span className="info-text">{volume && volume.name || this.props.id}</span>
          </Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={this.validate}
          onSubmit={this.onSubmit}
          initialValues={initialValues}>

          {this.props.volume ?
            <FormBody volume={volume} availabilityZones={availabilityZones}/>
            :
            <Modal.Body>
              <span className='spinner'></span>
              Loading...
            </Modal.Body>
          }

          <Modal.Footer>
            <Button onClick={this.close}>Cancel</Button>
            <Form.SubmitButton label='Clone'/>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
