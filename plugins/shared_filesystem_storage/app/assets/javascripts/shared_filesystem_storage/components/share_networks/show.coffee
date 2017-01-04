#= require react/tabs

{ div, span, br, button, a, table, tbody, thead, tr, th, td } = React.DOM
{ connect } = ReactRedux

ShowShareNetwork = ({
  close,
  shareNetwork,
  network,
  subnet
})->
  tabs= [{
    name: "Overview"
    uid: 'overview'
    content: table className: 'table no-borders',
      tbody null,
        tr null,
          th style: {width: '30%'}, 'Name'
          td null, shareNetwork.name
        tr null,
          th null, 'ID'
          td null, shareNetwork.id
        tr null,
          th null, 'Description'
          td null, shareNetwork.description
        tr null,
          th null, 'Cidr'
          td null, shareNetwork.cidr
        tr null,
          th null, 'IP Version'
          td null, shareNetwork.ip_version
        tr null,
          th null, 'Network Type'
          td null, shareNetwork.network_type
        tr null,
          th null, 'Neutron Network ID'
          td null, shareNetwork.neutron_net_id
        tr null,
          th null, 'Neutron Subnet ID'
          td null, shareNetwork.neutron_subnet_id
        tr null,
          th null, 'Project ID'
          td null, shareNetwork.project_id
  }]

  if network
    tabs.push
      name: "Neutron Network"
      uid: 'neutron-network'
      content: table className: 'table no-borders',
        tbody null,
          tr null,
            th style: {width: '30%'}, 'Name'
            td null, network.name
          tr null,
            th null, 'ID'
            td null, network.id
          tr null,
            th null, 'Description'
            td null, network.description
          tr null,
            th null, 'Shared'
            td null, if network.shared then 'Yes' else 'No'
          tr null,
            th null, 'Status'
            td null, network.status

  if subnet
    tabs.push
      name: 'Neutron Subnet'
      uid: 'neutron-subnet'
      content: table className: 'table no-borders',
        tbody null,
          tr null,
            th style: {width: '30%'}, 'Name'
            td null, subnet.name
          tr null,
            th null, 'ID'
            td null, subnet.id
          tr null,
            th null, 'Description'
            td null, subnet.description
          tr null,
            th null, 'Cidr'
            td null, subnet.cidr
          tr null,
            th null, 'Gateway IP'
            td null, subnet.gateway_ip
          tr null,
            th null, 'IP Version'
            td null, subnet.ip_version
          tr null,
            th null, 'Network ID'
            td null, subnet.network_id

  div null,
    div className: 'modal-body', React.createElement ReactTabs, tabsConfig: tabs

    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'

ShowShareNetwork = connect(
  (state,ownProps) ->
    network: (() ->
      return null if state.networks.isFetching
      state.networks.items.find (i) -> i.id==ownProps.shareNetwork.neutron_net_id
    )()
    subnet: (()->
      subnets = state.subnets[ownProps.shareNetwork.neutron_net_id]
      return null if !subnets or subnets.isFetching or !subnets.items
      subnets.items.find (i) -> i.id==ownProps.shareNetwork.neutron_subnet_id
    )()
)(ShowShareNetwork)

shared_filesystem_storage.ShowShareNetworkModal = ReactModal.Wrapper('Share Network Details', ShowShareNetwork, large:true)
