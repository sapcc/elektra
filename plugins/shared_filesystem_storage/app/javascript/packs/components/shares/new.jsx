import { Modal, Button } from 'react-bootstrap';
import { Link } from 'react-router-dom';

const FormElement = ({label, required = false, htmlFor, children}) => {
  return (
    <div className="form-group">
      <label className={`text $(required ? 'required' : 'optional') col-sm-4 control-label`} htmlFor={htmlFor}>
        { required && <abbr title="required">*</abbr>}
        {label}
      </label>
      <div className="col-sm-8">
        <div className="input-wrapper">{children}</div>
      </div>
    </div>
  )
};

const protocols = ['NFS','CIFS']

export default ({
  show,
  onHide,
  shareForm,
  shareNetworks,
  availabilityZones,
  handleSubmit,
  handleChange,
  handleNewShareNetwork
}) => {
  let share = shareForm.data || {}

  let onChange = (e) => {
    e.preventDefault()
    handleChange(e.target.name,e.target.value)
  };

  return <Modal show={show} onHide={onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
    <Modal.Header closeButton>
      <Modal.Title id="contained-modal-title-lg">New Share</Modal.Title>
    </Modal.Header>

    <form className='form form-horizontal' onSubmit={(e) => { e.preventDefault(); handleSubmit()}}>
      <Modal.Body>
        { shareForm.errors &&
          <div className='alert alert-error'>
            Errors
          </div>
        }

        <FormElement label='Name' htmlFor="share_name">
          <input className="string required form-control" type="text"
            name="name" id="share_name" value={share.name || ''}
            onChange={onChange}/>
        </FormElement>

        <FormElement label='Description'>
          <textarea className="text optional form-control" name="description"
            value={share.description || ''} onChange={onChange}/>
        </FormElement>

        <FormElement label='Protocol' required={true} htmlFor="share_proto">
          <select className="select required form-control" name='share_proto'
            id="share_proto" value={share.share_proto || ''} onChange={onChange}>
            <option></option>
            {protocols.map((protocol,index) =>
              <option value={protocol} key={index}>{protocol}</option>
            )}
          </select>
        </FormElement>

        <FormElement label='Size (GiB)' htmlFor="share_size" required={true}>
          <input className="integer required optional form-control" type="number"
            name="size" id="share_size" value={share.size || ''} onChange={onChange}/>
        </FormElement>

        <FormElement label='Availability Zone' htmlFor="share_az">
          { availabilityZones.isFetching ? (
            <span><span className='spinner'></span>Loading...</span>
          ) : (
            <div>
              <select name="availability_zone"
                className="required select form-control"
                value={share.availability_zone || ''} onChange={onChange}>
                <option></option>
                { availabilityZones.items.map((az,index) =>
                  <option value={az.id} key={index}>{az.name}</option>
                )}
              </select>

              { availabilityZones.items.length==0 &&
                <p className='help-block'>
                  <i className="fa fa-info-circle"></i>
                  No availability zones available.
                </p>
              }
            </div>
          )}
        </FormElement>


        <FormElement label='Share Network' htmlFor="share_network" required={true}>
          { shareNetworks.isFetching ? (
            <span><span className='spinner'></span>Loading...</span>
          ) : (
            <div>
              <select name="share_network_id"
                className="required select form-control"
                value={share.share_network_id || ''} onChange={onChange}>
                <option></option>
                {shareNetworks.items.map((sn,index) =>
                  <option value={sn.id} key={sn.id}>{sn.name}</option>
                )}
              </select>
              { shareNetworks.items.length==0 &&
                <p className='help-block'>
                  <i className="fa fa-info-circle"></i>
                  There are no share networks defined yet.
                  <Link to="/share-networks/new">Create a new share network.</Link>
                </p>
              }
            </div>
          )}
      </FormElement>

      </Modal.Body>
      <Modal.Footer>
        <Button onClick={onHide}>Cancel</Button>
        <Button bsStyle="primary" type="submit" disabled={!shareForm.isValid || shareForm.isSubmitting}>
          { shareForm.isSubmitting ? 'Please Wait ...' : 'Save' }
        </Button>
      </Modal.Footer>
    </form>
  </Modal>
}
