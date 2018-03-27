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
  state = {show: false}

  restoreUrl = (e) => {
    if (!this.state.show)
      this.props.history.replace(`/os-images/${this.props.activeTab}`)
  }

  hide = (e) => {
    if (e) e.stopPropagation()
    this.setState({show: false})
  }

  componentDidMount() {
    this.setState({
      show: this.props.image != null
    })
  }
  componentWillReceiveProps(nextProps) {
    this.setState({
      show: nextProps.image != null
    })
  }

  render() {
    let {image} = this.props

    return (
      <Modal
        show={this.state.show}
        onExited={this.restoreUrl}
        onHide={this.hide}
        bsSize="large"
        aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton={true}>
          <Modal.Title id="contained-modal-title-lg">Share {
              image
                ? image.name
                : ''
            }</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {image &&
            <table className='table no-borders'>
              <tbody>
                <Row label='Name' value={image.name}/>
                <Row label='ID' value={image.id}/>
                <Row label='Owner Project' value={image.owner}/>
                <Row label='Container Format' value={image.container_format}/>
                <Row label='Disk Format' value={image.disk_format}/>
                <Row label='Visibility' value={image.visibility}/>
                <Row label='Status' value={image.status}/>
                <Row label='Tags'>
                  {image.tags && image.tags.map((tag, index) => <div key={index}>{tag}</div>)}
                </Row>
                <Row label='Min Disk' value={image.min_disk && `${image.min_disk} GB`}/>
                <Row label='Protected' value={image.protected}/>
                <Row label='File' value={image.file}/>
                <Row label='Checksum' value={image.checksum}/>
                <Row label='Size'><PrettySize size={image.size}/></Row>
                <Row label='Min Ram' value={image.min_ram && `${image.min_ram} MB`}/>
                <Row label='Schema' value={image.schema}/>
                <Row label='Virtual Size'>
                  <PrettySize size={image.virtual_size}/>
                </Row>

                <Row label='Created At'>
                  <PrettyDate date={image.created_at}/>
                </Row>
                <Row label='Updated At'>
                  <PrettyDate date={image.updated_at}/>
                </Row>
              </tbody>
            </table>
          }
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.hide}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
