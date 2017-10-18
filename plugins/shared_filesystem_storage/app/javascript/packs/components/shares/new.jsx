import PropTypes from 'prop-types';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'elektra-form';

const protocols = ['NFS','CIFS']

let NewShareForm = ({
  onHide,
  show,
  values,
  onSubmit,
  resetForm,
  availabilityZones,
  shareNetworks
}) => {
  let hide = () => {
    resetForm()
    onHide()
  }

  let submit = (e) => {
    onSubmit(e, {onSuccess: hide})
  }

  return (
    <Modal show={show} onHide={hide} bsSize="large" aria-labelledby="contained-modal-title-lg">
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">New Share</Modal.Title>
      </Modal.Header>

      <form onSubmit={submit} className='form form-horizontal'>
        <Modal.Body>
          <Form.Errors/>

          <Form.ElementHorizontal label='Name' name="name">
            <Form.Input elementType='input' type='text' name='name'/>
          </Form.ElementHorizontal>

          <Form.ElementHorizontal label='Description' name="description">
            <Form.Input elementType='textarea' className="text optional form-control" name="description"/>
          </Form.ElementHorizontal>

          <Form.ElementHorizontal label='Protocol' required={true} name="share_proto">
            <Form.Input elementType='select' className="select required form-control" name='share_proto'>
              <option></option>
              {protocols.map((protocol,index) =>
                <option value={protocol} key={index}>{protocol}</option>
              )}
            </Form.Input>
          </Form.ElementHorizontal>

          <Form.ElementHorizontal label='Size (GiB)' name="size" required={true}>
            <Form.Input elementType='input' className="integer required optional form-control" type="number"
              name="size"/>
          </Form.ElementHorizontal>

          <Form.ElementHorizontal label='Availability Zone' name="share_az">
            { availabilityZones.isFetching ? (
              <span><span className='spinner'></span>Loading...</span>
            ) : (
              <div>
                <Form.Input elementType='select' name='availability_zone' className="required select form-control">
                  <option></option>
                  { availabilityZones.items.map((az,index) =>
                    <option value={az.id} key={index}>{az.name}</option>
                  )}
                </Form.Input>

                { availabilityZones.items.length==0 &&
                  <p className='help-block'>
                    <i className="fa fa-info-circle"></i>
                    No availability zones available.
                  </p>
                }
              </div>
            )}
          </Form.ElementHorizontal>


          <Form.ElementHorizontal label='Share Network' name="share_network" required={true}>
            { shareNetworks.isFetching ? (
              <span><span className='spinner'></span>Loading...</span>
            ) : (
              <div>
                <Form.Input elementType='select' name="share_network_id"
                  className="required select form-control">
                  <option></option>
                  {shareNetworks.items.map((sn,index) =>
                    <option value={sn.id} key={sn.id}>{sn.name}</option>
                  )}
                </Form.Input>
                { shareNetworks.items.length==0 &&
                  <p className='help-block'>
                    <i className="fa fa-info-circle"></i>
                    There are no share networks defined yet.
                    <Link to="/share-networks/new">Create a new share network.</Link>
                  </p>
                }
              </div>
            )}
          </Form.ElementHorizontal>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={hide}>Cancel</Button>
          <Form.SubmitButton label='Save'/>
        </Modal.Footer>
      </form>
    </Modal>
  )
}

export default Form({
  intialValues: {},
  validate: (values) => (values.share_proto && values.size && values.share_network_id && true),
  handleSubmit: (values, {handleSuccess,handleErrors}) => this.props.handleSuccess
})(NewShareForm)
