import { Modal, Button, Tabs, Tab } from 'react-bootstrap';

export default ({show, onHide, share}) => {
  let overview = () =>
    <table className='table no-borders'>
      <tbody>
        <tr>
          <th style={{width: '30%'}}>Name</th>
          <td>{share.name}</td>
        </tr>
        <tr>
          <th>ID</th>
          <td>{share.id}</td>
        </tr>
        <tr>
          <th>Status</th>
          <td>{share.status}</td>
        </tr>
        <tr>
          <th>Export Locations</th>
          <td>
            {share.export_locations ? (
              share.export_locations.map((location) =>
                <div key={location.id}>{location.path}</div>)
              ) : (<span className='spinner'></span>)
            }
          </td>
        </tr>
        <tr>
          <th>Availability zone</th>
          <td>{share.availability_zone}</td>
        </tr>
        <tr>
          <th style={ {width: '30%'}}>Size</th>
          <td>{share.size+' GiB'}</td>
        </tr>
        <tr>
          <th>Protocol</th>
          <td>{share.share_proto}</td>
        </tr>
        <tr>
          <th>Share Type</th>
          <td>{share.share_type}</td>
        </tr>
        <tr>
          <th>Share network</th>
          <td>{share.share_network_id}</td>
        </tr>
        <tr>
          <th>Created At</th>
          <td>{share.created_at}</td>
        </tr>
        <tr>
          <th>Host</th>
          <td>{share.host}</td>
        </tr>
      </tbody>
    </table>

  let metadata = () =>
    share.metadata && Object.keys(share.metadata).length>0 &&
      <table className="table no-borders">
        <tbody>
          Object.keys(share.metadata).map((key) =>
            <tr>
              <th style={{width: '30%'}}>{key}</th>
              <td>{share.metadata[key]}</td>
            </tr>
          )
        </tbody>
      </table>

  return (
    <Modal show={show} onHide={onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">Share {share ? share.name : ''}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        { share &&
          ( share.metadata && Object.keys(share.metadata).length>0 ? (
            <Tabs defaultActiveKey={1} id="share">
              <Tab eventKey={1} title="Overview">{overview()}</Tab>
              <Tab eventKey={2} title="Metadata">{metadata()}</Tab>
            </Tabs>
          ) : (
            overview()
          ))
        }
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={onHide}>Close</Button>
      </Modal.Footer>
    </Modal>
  )
}
