import { Modal, Button } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { FormElement, FormElementHorizontal, FormInput, SubmitButton, FormErrors, FormFactory } from 'elektra-form';
const protocols = ['NFS','CIFS']

let Form = FormFactory('test5')

export default ({
  show,
  onHide,
  shareNetworks,
  availabilityZones,
  handleSubmit,
  handleNewShareNetwork
}) => {

  let validate = (values) => {
    return (values.share_proto && values.size && values.share_network_id)
  }

  let onSubmit = (values, {handleSuccess, handleErrors}) => {
    console.log('submit')
    handleSuccess()
  }

  return <Modal show={show} onHide={onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
    <Modal.Header closeButton>
      <Modal.Title id="contained-modal-title-lg">New Share</Modal.Title>
    </Modal.Header>

    <Form className='form form-horizontal' onSubmit={onSubmit} valid={validate}>
      <Modal.Body>
        <FormErrors/>
        <FormElementHorizontal label='Name' name="name">
          <FormInput elementType='input' type='text' name='name'/>
        </FormElementHorizontal>

        <FormElementHorizontal label='Description' name="description">
          <FormInput elementType='textarea' className="text optional form-control" name="description"/>
        </FormElementHorizontal>

        <FormElementHorizontal label='Protocol' required={true} name="share_proto">
          <FormInput elementType='select' className="select required form-control" name='share_proto'>
            <option></option>
            {protocols.map((protocol,index) =>
              <option value={protocol} key={index}>{protocol}</option>
            )}
          </FormInput>
        </FormElementHorizontal>

        <FormElementHorizontal label='Size (GiB)' name="size" required={true}>
          <FormInput elementType='input' className="integer required optional form-control" type="number"
            name="size"/>
        </FormElementHorizontal>

        <FormElementHorizontal label='Availability Zone' name="share_az">
          { availabilityZones.isFetching ? (
            <span><span className='spinner'></span>Loading...</span>
          ) : (
            <div>
              <FormInput elementType='select' name='availability_zone' className="required select form-control">
                <option></option>
                { availabilityZones.items.map((az,index) =>
                  <option value={az.id} key={index}>{az.name}</option>
                )}
              </FormInput>

              { availabilityZones.items.length==0 &&
                <p className='help-block'>
                  <i className="fa fa-info-circle"></i>
                  No availability zones available.
                </p>
              }
            </div>
          )}
        </FormElementHorizontal>


        <FormElementHorizontal label='Share Network' name="share_network" required={true}>
          { shareNetworks.isFetching ? (
            <span><span className='spinner'></span>Loading...</span>
          ) : (
            <div>
              <FormInput elementType='select' name="share_network_id"
                className="required select form-control">
                <option></option>
                {shareNetworks.items.map((sn,index) =>
                  <option value={sn.id} key={sn.id}>{sn.name}</option>
                )}
              </FormInput>
              { shareNetworks.items.length==0 &&
                <p className='help-block'>
                  <i className="fa fa-info-circle"></i>
                  There are no share networks defined yet.
                  <Link to="/share-networks/new">Create a new share network.</Link>
                </p>
              }
            </div>
          )}
        </FormElementHorizontal>

      </Modal.Body>
      <Modal.Footer>
        <Button onClick={onHide}>Cancel</Button>
        <SubmitButton/>
      </Modal.Footer>
    </Form>
  </Modal>
}
