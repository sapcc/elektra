{tr,td,br,span,div,ul,li,button,a,i} = React.DOM
{ connect } = ReactRedux

ShareNetworkItem = ({
  shareNetwork,
  handleShow,
  handleDelete,
  handleEdit,
  handleShareNetworkSecurityServices,
  network,
  subnet
})->
  #console.log shares
  className = if shareNetwork.isDeleting
    'updating'
  else if shareNetwork.isNew
    'bg-info'
  else
    ''

  tr {className: className},
    td null,
      if shareNetwork.isNew
        a
          className: ''
          title: "Empty Network",
          tabIndex: "0",
          role: "button",
          "data-toggle": "popover",
          "data-placement": "top",
          "data-trigger": "focus",
          "data-content": "This network does not contain any shares or security services. Please note that once a share is created on this network, you will no longer be able to add a security service. Please add the security service first if necessary.",
          ref: ((el) ->$(el).popover()),
          i className: 'fa fa-fw fa-info-circle'

    td null,
      if shareNetwork.permissions.get
        a href: "#", onClick: ((e) -> e.preventDefault(); handleShow(shareNetwork)), shareNetwork.name
      else
        shareNetwork.name

    td null,
      if network
        if network=='loading'
          span className: 'spinner'
        else
          div null,
            network.name
            if network['router:external']
              i className: "fa fa-fw fa-globe", "data-toggle": "tooltip", "data-placement": "right", title: "External Network"
            if network.shared
              i className: "fa fa-fw fa-share-alt", "data-toggle": "tooltip",  "data-placement": "right", title: "Shared Network"
      else
        'Not found'

    td null,
      if subnet
        if subnet=='loading'
          span className: 'spinner'
        else
          div null, "#{subnet.name} #{subnet.cidr}"
      else
        'Not found'

    td { className: "snug" },
      if shareNetwork.permissions.delete or shareNetwork.permissions.update
        div { className: 'btn-group' },
          button { className: 'btn btn-default btn-sm dropdown-toggle', type: 'button', 'data-toggle': 'dropdown', 'aria-expanded': true},
            span {className: 'fa fa-cog' }

          ul { className: 'dropdown-menu dropdown-menu-right', role: "menu" },
            if shareNetwork.permissions.delete
              li null,
                a { href: '#', onClick: ((e) -> e.preventDefault(); handleDelete(shareNetwork.id))}, 'Delete'
            if shareNetwork.permissions.update
              li null,
                a { href: '#', onClick: ((e) -> e.preventDefault(); handleEdit(shareNetwork)) }, 'Edit'
            if shareNetwork.permissions.update
              li null,
                a { href: '#', onClick: ((e) -> e.preventDefault(); console.log(shareNetwork); handleShareNetworkSecurityServices(shareNetwork.id)) }, 'Security Services'

shared_filesystem_storage.ShareNetworkItem = ShareNetworkItem
