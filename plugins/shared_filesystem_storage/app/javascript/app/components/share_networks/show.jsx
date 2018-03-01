import { Link } from 'react-router-dom';
import { Modal, Button, Tabs, Tab } from 'react-bootstrap';

const Row = ({label,value,children}) => {
  return (
    <tr>
      <th style={{width: '30%'}}>{label}</th>
      <td>{value || children}</td>
    </tr>
  )
};

export default class ShowShareNetwork extends React.Component {
  constructor(props){
  	super(props);
  	this.state = { show: props.shareNetwork!=null };
    this.close = this.close.bind(this)
  }

  close(e) {
    if(e) e.stopPropagation()
    //this.props.history.goBack()
    this.setState({show: false})
    setTimeout(() => this.props.history.replace('/share-networks'),300)
  }

  componentWillReceiveProps(nextProps) {
    this.setState({show: nextProps.shareNetwork!=null})
  }

  renderOverview(shareNetwork) {
    return (
      <table className='table no-borders'>
        <tbody>
          <Row label='Name' value={shareNetwork.name}/>
          <Row label='ID' value={shareNetwork.id}/>
          <Row label='Description' value={shareNetwork.description}/>
          <Row label='Cidr' value={shareNetwork.cidr}/>
          <Row label='IP Version' value={shareNetwork.ip_version}/>
          <Row label='Network Type' value={shareNetwork.network_type}/>
          <Row label='Neutron Network ID' value={shareNetwork.neutron_net_id}/>
          <Row label='Neutron Subnet ID' value={shareNetwork.neutron_subnet_id}/>
          <Row label='Project ID' value={shareNetwork.project_id}/>
        </tbody>
      </table>
    )
  }

  renderNetwork(network){
    if(!network) return null
    return (
      <table className='table no-borders'>
        <tbody>
          <Row label='Name' value={network.name}/>
          <Row label='ID' value={network.id}/>
          <Row label='Description' value={network.description}/>
          <Row label='Shared' value={network.shared ? 'Yes' : 'No'}/>
          <Row label='Status' value={network.status}/>
        </tbody>
      </table>
    )
  }

  renderSubnet(subnet){
    if(!subnet) return null
    return(
      <table className='table no-borders'>
        <tbody>
          <Row label='Name' value={subnet.name}/>
          <Row label='ID' value={subnet.id}/>
          <Row label='Description' value={subnet.description}/>
          <Row label='Cidr' value={subnet.cidr}/>
          <Row label='Gateway IP' value={subnet.gateway_ip}/>
          <Row label='IP Version' value={subnet.ip_version}/>
          <Row label='Network ID' value={subnet.network_id}/>
        </tbody>
      </table>
    )
  }


  render() {
    let { isFetchingShareNetwork, isFetchingSubnet, isFetchingNetwork, shareNetwork, subnet, network } = this.props
    return (
      <Modal show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Share Network {shareNetwork ? shareNetwork.name : ''}
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          { isFetchingNetwork ? (
            <span className='spinner'/>
          ) : (
            !shareNetwork ? (
              <span>Could not load share network</span>
            ) : (
              <Tabs defaultActiveKey={1} id="shareNetwork">
                <Tab eventKey={1} title="Overview">{this.renderOverview(shareNetwork)}</Tab>
                <Tab eventKey={2} title="Network">
                  {isFetchingNetwork ? <span className='spinner'/> : this.renderNetwork(network)}
                </Tab>
                <Tab eventKey={3} title="Subnet">
                  {isFetchingSubnet ? <span className='spinner'/> : this.renderSubnet(subnet)}
                </Tab>
              </Tabs>
            )
          )}
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.close}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
