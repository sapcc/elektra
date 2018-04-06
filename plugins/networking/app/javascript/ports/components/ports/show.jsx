import { Modal, Button, Tabs, Tab } from 'react-bootstrap';
import { Link } from 'react-router-dom';

const Row = ({label,value,children}) => {
  return (
    <tr>
      <th style={{width: '30%'}}>{label}</th>
      <td>{value || children}</td>
    </tr>
  )
};

export default class ShowPortModal extends React.Component{
  constructor(props){
  	super(props);
  	this.state = {show: true}
    this.close = this.close.bind(this)
    this.renderNetwork = this.renderNetwork.bind(this)
    this.renderSubnets = this.renderSubnets.bind(this)
  }

  close(e) {
    if(e) e.stopPropagation()
    //this.props.history.goBack()
    this.setState({show: false})
    setTimeout(() => this.props.history.replace('/ports'),300)
  }

  componentDidMount() {
    this.loadDependencies(this.props)
  }

  componentWillReceiveProps(nextProps) {
    this.loadDependencies(nextProps)
  }

  loadDependencies(props) {
    props.loadPortsOnce()
    props.loadNetworksOnce()
    props.loadSubnetsOnce()
  }

  renderNetwork(port) {
    let network = this.props.networks.items.find((n) => n.id==port.network_id)

    return (
      <div>
        { this.props.networks.isFetching && <span className='spinner'></span>}
        { network && <span>{network.name}<br/></span> }
        <span className={ network && 'info-text'}>{port.network_id}</span>
      </div>
    )
  }

  renderSubnets(port) {
    return (port.fixed_ips || []).map((ip, index) => {
      let subnet = this.props.subnets.items.find((s) => s.id==ip.subnet_id)

      return (
        <div key={index}>
          <b>{ip.ip_address} </b>
          { this.props.subnets.isFetching && <span className='spinner'></span>}
          { subnet && <span>{subnet.name}<br/></span> }
          <span className='info-text'>{ip.subnet_id}</span>
        </div>
      )
    })
  }

  renderTable(port) {
    let fixed_ips = port.fixed_ips || []

    return (
      <table className='table no-borders'>
        <tbody>
          <Row label='Port ID' value={port.id}/>
          <Row label='Network'>{this.renderNetwork(port)}</Row>
          <Row label='IP'>{ this.renderSubnets(port) }</Row>
          <Row label='Description' value={port.description}/>
          <Row label='Name' value={port.name}/>
          <Row label='Device Owner' value={port.device_owner}/>
          <Row label='Device ID' value={port.device_id}/>
          <Row label='Created at' value={port.created_at}/>
          <Row label='Updated at' value={port.created_at}/>
          <Row label='Project ID' value={port.tenant_id || port.project_id}/>
          <Row label='Status' value={port.status}/>
          <Row label='Security Groups' value={port.security_groups}/>
        </tbody>
      </table>
    )

    // admin_state_up
    // allowed_address_pairs
    // binding:host_id
    // binding:profile
    // binding:vif_details
    // binding:vif_type
    // binding:vnic_type
    // data_plane_status
    // device_id
    // device_owner
    // dns_assignment
    // dns_domain
    // dns_name
    // extra_dhcp_opts
    // ip_allocation
    // mac_address
    // port_security_enabled
    // revision_number
  }

  render(){
    return(
      <Modal show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Port {this.port && (this.port.description || this.port.id)}
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          { this.props.port ?
           this.renderTable(this.props.port)
           : <span className='spinner'></span>
         }
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.close}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
