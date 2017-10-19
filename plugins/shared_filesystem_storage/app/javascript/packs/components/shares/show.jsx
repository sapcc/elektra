import { Modal, Button, Tabs, Tab } from 'react-bootstrap';

const Row = ({label,value,children}) => {
  return (
    <tr>
      <th style={{width: '30%'}}>{label}</th>
      <td>{value || children}</td>
    </tr>
  )
};

export default ({onHide, share}) => {
  let overview = () =>
    <table className='table no-borders'>
      <tbody>
        <Row label='Name' value={share.name}/>
        <Row label='Description' value={share.description}/>
        <Row label='ID' value={share.id}/>
        <Row label='Status' value={share.status}/>
        <Row label='Export Locations'>
          {share.export_locations ? (
            share.export_locations.map((location) =>
              <div key={location.id}>{location.path}</div>)
            ) : (<span className='spinner'></span>)
          }
        </Row>
        <Row label='Availability zone' value={share.availability_zone}/>
        <Row label='Size' value={share.size+' GiB'}/>
        <Row label='Protocol' value={share.share_proto}/>
        <Row label='Share Type' value={share.share_type}/>
        <Row label='Share network' value={share.share_network_id}/>
        <Row label='Created At' value={share.created_at}/>
        <Row label='Host' value={share.host}/>
      </tbody>
    </table>

  let metadata = () =>
    share.metadata && Object.keys(share.metadata).length>0 &&
      <table className="table no-borders">
        <tbody>
          Object.keys(share.metadata).map((key) =>
            <Row label={key} value={share.metadata[key]}/>
          )
        </tbody>
      </table>

  return (
    <Modal show={share!=null} onHide={onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
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
