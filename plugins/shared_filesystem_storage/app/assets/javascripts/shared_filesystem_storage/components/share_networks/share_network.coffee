{tr,td,br,a,span,div,button,ul,li,i} = React.DOM
{ConfirmDialog, ReactErrorDialog} = shared_filesystem_storage

shared_filesystem_storage.ShareNetwork = React.createClass
  getInitialState: ->
    loading: false

  componentDidMount: () ->
    @props.loadSubnets(@props.shareNetwork.neutron_net_id) unless @props.subnets[@props.shareNetwork.neutron_net_id]
    $(@refs.row).find('[data-toggle="tooltip"]').tooltip()

  componentDidUpdate: ->
    $(@refs.row).find('[data-toggle="tooltip"]').tooltip()

  handleDelete: (e) ->
    e.preventDefault()
    ConfirmDialog.ask 'Are you sure?',
      #validationTerm: @props.shareNetwork.name
      description: 'Would you like to delete this shared network?'
      confirmLabel: 'Yes, delete it!'
    .then => @deleteShareNetwork()
    .fail -> null

  deleteShareNetwork: ->
    @setState loading: true
    @props.ajax.delete "share-networks/#{ @props.shareNetwork.id }",
      success: () =>
        @props.handleDeleteShareNetwork @props.shareNetwork
      error: ( jqXHR, textStatus, errorThrown ) =>

        errors = JSON.parse(jqXHR.responseText)
        message = ul null,
          li(key: name, "#{name}: #{error}") for name,error of errors if errors
        ReactErrorDialog.show(errorThrown, description: message)
        @setState loading: false


  neutronNetwork: ->
    if @props.networks and @props.networks.length>0
      for network in @props.networks
        if network.id==@props.shareNetwork.neutron_net_id
          return network
    return null


  neutronSubnet: () ->
    if @props.subnets[@props.shareNetwork.neutron_net_id]
      for subnet in @props.subnets[@props.shareNetwork.neutron_net_id]
        if subnet.id==@props.shareNetwork.neutron_subnet_id
          return subnet
    return null

  handleEdit: (e) ->
    e.preventDefault()
    @props.handleEditShareNetwork(@props.shareNetwork)

  handleShow: (e) ->
    e.preventDefault()
    @props.handleShowShareNetwork(@props.shareNetwork)

  render: ->
    network = @neutronNetwork()
    subnet = @neutronSubnet()

    tr {className: ('updating' if @state.loading), ref: 'row'},
      td null,
        if @props.shareNetwork.permissions.get
          a href: "#", onClick: @handleShow, @props.shareNetwork.name
        else
          @props.shareNetwork.name
      td null,
        if network
          div null,
            network.name
            if network['router:external']
              i className: "fa fa-fw fa-globe", "data-toggle": "tooltip", "data-placement": "right", title: "External Network"
            if network.shared
              i className: "fa fa-fw fa-share-alt", "data-toggle": "tooltip",  "data-placement": "right", title: "Shared Network"
        else
          #span className: 'spinner'
          i className: 'spinner'

      td null,
        if subnet
          div null, "#{subnet.name} #{subnet.cidr}"
        else
          span className: 'spinner'

      td { className: "snug" },
        if @props.shareNetwork.permissions.delete or @props.shareNetwork.permissions.update
          div { className: 'btn-group' },
            button { className: 'btn btn-default btn-sm dropdown-toggle', type: 'button', 'data-toggle': 'dropdown', 'aria-expanded': true},
              span {className: 'fa fa-cog' }

            ul { className: 'dropdown-menu dropdown-menu-right', role: "menu" },
              if @props.shareNetwork.permissions.delete
                li null,
                  a { href: '#', onClick: @handleDelete}, 'Delete'
              if @props.shareNetwork.permissions.update
                li null,
                  a { href: '#', onClick: @handleEdit }, 'Edit'
