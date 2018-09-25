import {Modal, Button, Tabs, Tab} from 'react-bootstrap';
import {Link} from 'react-router-dom';
import {PrettyDate} from 'lib/components/pretty_date';
import {PrettySize} from 'lib/components/pretty_size';

const Row = ({label, value, children}) => {
  return (<tr>
    <th style={ {width: '30%'} }>{label}</th>
    <td>{value || children}</td>
  </tr>)
};

export default class ShowModal extends React.Component {
  state = {show: false, loadError: null}

  restoreUrl = (e) => {
    if (!this.state.show) {
      this.props.history.replace(
        this.props.location.pathname.replace(/(.+)\/.+\/show/,'$1')
      )
    }
  }

  hide = (e) => {
    if (e) e.stopPropagation()
    this.setState({show: false})
  }

  componentDidMount() {
    this.setState({
      show: this.props.id != null
    })
    if(!this.props.volume) {
      this.props.loadVolume().catch((loadError) => this.setState({loadError}))
    }
  }

  componentWillReceiveProps(nextProps) {
    this.setState({
      show: nextProps.id != null,
      loadError: nextProps.volume != null ? null : this.state.loadError
    })
  }

  renderOverview(volume){
    if (this.state.loadError) {
      return (
        <React.Fragment>
          <div className='text-danger'>
            <h4>Could not load volume!</h4>
            <p>{this.state.loadError}</p>
          </div>
        </React.Fragment>
      )
    }

    if (!volume) {
      return <React.Fragment><span className='spinner'></span> Loading...</React.Fragment>
    }

    return(
      <table className='table no-borders'>
        <tbody>
          <Row label='Name' value={volume.name}/>
          <Row label='ID' value={volume.id}/>
          <Row label='Description' value={volume.description}/>
          <Row label='Size (GB)' value={volume.size}/>
          <Row label='Type' value={volume.volume_type}/>
          <Row label='Availability Zone' value={volume.availability_zone}/>
          <Row label='Status' value={volume.status}/>
          <Row label='Replication Status' value={volume.replication_status}/>

          <Row label='Metadata'>
            {volume.metadata && Object.keys(volume.metadata).map((key, index) =>
              <div key={index}>{key}: {volume.metadata[key]}</div>
            )}
          </Row>

          <Row label='User'>
            {volume.user_name ?
              <React.Fragment>
                {volume.user_name}
                <br/>
                <span className='info-text'>{volume.user_id}</span>
              </React.Fragment>
              :
              volume.user_id
            }
          </Row>
          <Row label='Bootable' value={volume.bootable}/>
          <Row label='Encrypted' value={volume.encrypted}/>
          <Row label='Multiattach' value={volume.multiattach}/>
          <Row label='Snapshot ID' value={volume.snapshot_id}/>
          <Row label='Source Volume ID' value={volume.source_volid}/>
          <Row label='Consistency Group ID' value={volume.consistencygroup_id}/>

          <Row label='Created At'>
            <PrettyDate date={volume.created_at}/>
          </Row>
          <Row label='Updated At'>
            <PrettyDate date={volume.updated_at}/>
          </Row>
        </tbody>
      </table>
    )
  }

  renderAttachments(volume){
    if(!volume) return null

    return(
      <table className='table'>
        <thead>
          <tr>
            <th>Attachment ID</th>
            <th>Server</th>
            <th>Device</th>
            <th>Attached At</th>
          </tr>
        </thead>
        <tbody>
          {volume.attachments.map((attachment,index) =>
            <tr key={index}>
              <td>{attachment.attachment_id}</td>
              <td>
                {attachment.server_name ?
                  <React.Fragment>
                    {attachment.server_name}
                    <br/>
                    <span className='info-text'>{attachment.server_id}</span>
                  </React.Fragment>
                  :
                  attachment.server_id
                }
              </td>
              <td>{attachment.device}</td>
              <td><PrettyDate date={attachment.attached_at}/></td>
            </tr>
          )}
        </tbody>
      </table>
    )
  }

  render() {
    let {volume} = this.props

    return (
      <Modal
        show={this.state.show}
        onExited={this.restoreUrl}
        onHide={this.hide}
        dialogClassName="modal-xl"
        aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton={true}>
          <Modal.Title id="contained-modal-title-lg">Volume {
              volume
                ? volume.name
                : <span className='info-text'>{this.props.id}</span>
            }
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Tabs defaultActiveKey={'overview'} id={'overview'}>
            <Tab eventKey='overview' title="Overview">
              {this.renderOverview(volume)}
            </Tab>
            {volume && volume.attachments && volume.attachments.length>0 &&
              <Tab eventKey='attachments' title="Attachments">
                {this.renderAttachments(volume)}
              </Tab>
            }
          </Tabs>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.hide}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
