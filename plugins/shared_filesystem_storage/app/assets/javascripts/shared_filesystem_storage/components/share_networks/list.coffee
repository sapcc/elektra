#= require shared_filesystem_storage/components/share_networks/item

{ connect } = ReactRedux
{ div, table, thead, tbody, tr, th, td, span, button } = React.DOM
{
  ShareNetworkItem,
  fetchShareNetworksIfNeeded,
  fetchNetworksIfNeeded,
  fetchNetworkSubnetsIfNeeded,
  openNewShareNetworkDialog,
  openDeleteShareNetworkDialog,
  openShowShareNetworkDialog,
  openEditShareNetworkDialog,
} = shared_filesystem_storage

ShareNetworkList = React.createClass
  componentDidMount: ->
    @loadDependencies(@props)

  componentWillReceiveProps: (nextProps) ->
    @loadDependencies(nextProps)

  loadDependencies: (props) ->
    if props.active
      props.loadShareNetworksOnce()
      props.loadNetworksOnce()
      props.loadSubnetsOnce(shareNetwork.neutron_net_id) for shareNetwork in props.shareNetworks

  network: (shareNetwork)->
    return 'loading' if @props.networks.isFetching
    @props.networks.items.find((network)=> network.id==shareNetwork.neutron_net_id)

  subnet: (shareNetwork)->
    networkSubnets = @props.subnets[shareNetwork.neutron_net_id]
    return null unless networkSubnets
    return 'loading' if networkSubnets.isFetching
    return null unless networkSubnets.items
    networkSubnets.items.find((subnet)-> subnet.id==shareNetwork.neutron_subnet_id)

  render: ->
    div null,
      if @props.permissions.create
        div className: 'toolbar',
          button
            type: "button",
            className: "btn btn-primary",
            onClick: ((e) => e.preventDefault(); @props.handleNewShareNetwork()),
            'Create new'
      if @props.isFetching
        div null,
          span className: 'spinner', null
          'Loading...'
      else
        table { className: 'table share-networks' },
          thead null,
            tr null,
              th null, 'Name'
              th null, 'Neutron Net'
              th null, 'Neutron Subnet'
              th null, ''
          tbody null,
            if @props.shareNetworks.length==0
              tr null,
                td {colSpan: 6},'No Share Networks found.'
            for shareNetwork in @props.shareNetworks
              React.createElement ShareNetworkItem,
                key: shareNetwork.id,
                shareNetwork: shareNetwork,
                handleShow: @props.handleShow,
                handleEdit: @props.handleEdit,
                handleDelete: @props.handleDelete,
                network: @network(shareNetwork),
                subnet: @subnet(shareNetwork)

ShareNetworkList = connect(
  (state) ->
    shareNetworks: state.shareNetworks.items
    isFetching: state.shareNetworks.isFetching
    networks: state.networks
    subnets: state.subnets
  (dispatch) ->
    loadShareNetworksOnce: () -> dispatch(fetchShareNetworksIfNeeded())
    loadNetworksOnce: () -> dispatch(fetchNetworksIfNeeded())
    handleNewShareNetwork: () -> dispatch(openNewShareNetworkDialog())
    loadSubnetsOnce: (neutronNetworkId) -> dispatch(fetchNetworkSubnetsIfNeeded(neutronNetworkId))
    handleShow: (shareNetwork) -> dispatch(openShowShareNetworkDialog(shareNetwork))
    handleDelete: (shareNetworkId) -> dispatch(openDeleteShareNetworkDialog(shareNetworkId))
    handleEdit: (shareNetwork) -> dispatch(openEditShareNetworkDialog(shareNetwork))
)(ShareNetworkList)

shared_filesystem_storage.ShareNetworkList = ShareNetworkList
