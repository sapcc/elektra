#= require shared_filesystem_storage/components/shares/item
#= require components/transition_groups

{ connect } = ReactRedux
{ div, button, span, table, thead, tbody, tr, th, td, i, a } = React.DOM
{ ShareItem,
  fetchSharesIfNeeded,
  fetchShareNetworksIfNeeded,
  fetchAvailabilityZonesIfNeeded,
  openNewShareDialog,
  fetchShareRulesIfNeeded,
  reloadShare ,
  openShowShareDialog,
  openDeleteShareDialog,
  openEditShareDialog,
  openShareAccessControlDialog,
  selectTab,
  openNewSnapshotDialog
} = shared_filesystem_storage

ShareList = React.createClass
  componentDidMount: ->
    @loadDependencies(@props)

  componentWillReceiveProps: (nextProps) ->
    @loadDependencies(nextProps)

  loadDependencies:(props)->
    if props.active
      props.loadSharesOnce()
      props.loadShareNetworksOnce()
      props.loadAvailabilityZonesOnce()
      props.loadShareRulesOnce(share.id) for share in @props.shares

  shareNetwork: (share) ->
    for network in @props.shareNetworks.items
      return network if network.id==share.share_network_id
    return null

  shareRules: (share)->
    rules = @props.shareRules[share.id]
    return null unless rules
    return 'loading' if rules.isFetching
    rules.items

  render: ->
    div null,
      if @props.permissions.create
        div className: 'toolbar',
          disabled=(@props.shareNetworks.isFetching or !@props.shareNetworks.items or @props.shareNetworks.items.length==0)

          if !@props.shareNetworks.isFetching and @props.shareNetworks.items and @props.shareNetworks.items.length==0
            ReactTransitionGroups.Fade null,
              span className: "pull-right",
                a
                  className: 'text-warning'
                  title: "No Share Network found",
                  tabIndex: "0",
                  role: "button",
                  "data-toggle": "popover",
                  "data-placement": "top",
                  "data-trigger": "focus",
                  "data-content": "Please create a Share Network first.",
                  ref: ((el) ->$(el).popover()),
                  i className: 'fa fa-fw fa-exclamation-triangle fa-2'
                #a onClick: ((e) => e.preventDefault(); @props.handleNewShareNetwork()), href: '#', 'Please create a Share Network first.'

          button
            type: "button",
            className: "btn btn-primary",
            disabled: disabled,
            onClick: ((e) => e.preventDefault(); @props.handleNewShare()),
            'Create new'

      if @props.isFetching
        span className: 'spinner'
      else

        table { className: 'table shares' },
          thead null,
            tr null,
              th null, 'Name'
              th null,
                'AZ'
                i className: 'fa fa-fw fa-info-circle',
                "data-toggle": "tooltip",  "data-placement": "top",
                title: "Availability Zone",
                ref: ((el) ->$(el).tooltip())
              th null, 'Protocol'
              th null, 'Size'
              th null, 'Status'
              th style:{width: '30%'}, 'Network'
              th null, ''
          tbody null,
            if @props.shares.length>0
              for share in @props.shares
                React.createElement ShareItem,
                  key: share.id,
                  share: share,
                  shareRules: @shareRules(share)
                  shareNetwork: @shareNetwork(share)
                  handleEdit: @props.handleEdit
                  handleDelete: @props.handleDelete
                  handleShow: @props.handleShow
                  handleSnapshot: @props.handleSnapshot
                  handleAccessControl: @props.handleAccessControl
                  reloadShare: @props.reloadShare
            else
              tr null,
                td { colSpan: 6 }, 'No Shares found.'

shared_filesystem_storage.ShareList  = connect(
  (state) ->
    shares: state.shares.items
    isFetching: state.shares.isFetching
    shareNetworks: state.shareNetworks
    shareRules: state.shareRules
  (dispatch) ->
    loadSharesOnce: () -> dispatch(fetchSharesIfNeeded())
    loadShareNetworksOnce: () -> dispatch(fetchShareNetworksIfNeeded())
    loadAvailabilityZonesOnce: () -> dispatch(fetchAvailabilityZonesIfNeeded())
    handleNewShare: () -> dispatch(openNewShareDialog())
    loadShareRulesOnce: (shareId) -> dispatch(fetchShareRulesIfNeeded(shareId))
    handleShow: (shareId) -> dispatch(openShowShareDialog(shareId))
    reloadShare: (shareId) -> dispatch(reloadShare(shareId))
    handleDelete: (shareId) -> dispatch(openDeleteShareDialog(shareId))
    handleEdit: (share) -> dispatch(openEditShareDialog(share))
    handleSnapshot: (shareId) -> dispatch(openNewSnapshotDialog(shareId))
    handleAccessControl: (shareId,networkId) -> dispatch(openShareAccessControlDialog(shareId,networkId))
    handleNewShareNetwork: () ->
      dispatch(selectTab('share-networks'))
      dispatch(openNewShareNetworkDialog())
)(ShareList)
