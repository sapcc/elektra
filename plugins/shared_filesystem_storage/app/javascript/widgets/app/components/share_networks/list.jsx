/* eslint-disable react/no-unescaped-entities */
import { DefeatableLink } from "lib/components/defeatable_link"
import { policy } from "lib/policy"
import { Popover, OverlayTrigger } from "react-bootstrap"
import ShareNetworkItem from "./item"
import React from "react"

const CreateNewButton = () => {
  if (!policy.isAllowed("shared_filesystem_storage:share_network_create")) {
    const popover = (
      <Popover
        id="popover-no-create-permission"
        title="Missing Create Permission"
      >
        You don't have permission to create a share network. Please check if you
        have the role sharedfilesystem_admin.
      </Popover>
    )

    return (
      <OverlayTrigger
        overlay={popover}
        placement="top"
        delayShow={300}
        delayHide={150}
      >
        <button className="btn btn-primary disabled">
          <i className="fa fa-fw fa-exclamation-triangle fa-2"></i> Create New
        </button>
      </OverlayTrigger>
    )
  }

  return (
    <DefeatableLink to="/share-networks/new" className="btn btn-primary">
      Create New
    </DefeatableLink>
  )
}

export default class ShareNetworkList extends React.Component {
  constructor(props) {
    super(props)
    this.loadDependencies = this.loadDependencies.bind(this)
    this.network = this.network.bind(this)
    this.subnet = this.subnet.bind(this)
  }

  componentDidMount() {
    this.loadDependencies(this.props)
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    this.loadDependencies(nextProps)
  }

  loadDependencies(props) {
    if (props.active) {
      props.loadShareNetworksOnce()
      props.loadSecurityServicesOnce()
      props.loadNetworksOnce()
      for (let shareNetwork of props.shareNetworks) {
        props.loadSubnetsOnce(shareNetwork.neutron_net_id)
      }
    }
  }

  network(shareNetwork) {
    if (this.props.networks.isFetching) return "loading"
    if (!this.props.networks.items) return ""
    // find network
    return this.props.networks.items.find(
      (item) => item.id == shareNetwork.neutron_net_id
    )
  }

  subnet(shareNetwork) {
    let networkSubnets = this.props.subnets[shareNetwork.neutron_net_id]
    if (!networkSubnets) return null
    if (networkSubnets.isFetching) return "loading"
    if (!networkSubnets.items) return null
    return networkSubnets.items.find(
      (item) => item.id == shareNetwork.neutron_subnet_id
    )
  }

  render() {
    return (
      <>
        <div className="toolbar">
          <div className="main-buttons">
            <CreateNewButton />
          </div>
        </div>

        {this.props.isFetching ? (
          <div>
            <span className="spinner" />
            Loading...
          </div>
        ) : (
          <table className="table share-networks">
            <thead>
              <tr>
                <th></th>
                <th>Name</th>
                <th>Neutron Net</th>
                <th>Neutron Subnet</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {this.props.shareNetworks.length == 0 && (
                <tr>
                  <td colSpan="5">No Share Networks found.</td>
                </tr>
              )}
              {this.props.shareNetworks.map((shareNetwork, index) => (
                <ShareNetworkItem
                  key={shareNetwork.id}
                  shareNetwork={shareNetwork}
                  handleDelete={this.props.handleDelete}
                  network={this.network(shareNetwork)}
                  subnet={this.subnet(shareNetwork)}
                  policy={this.props.policy}
                />
              ))}
            </tbody>
          </table>
        )}
      </>
    )
  }
}
