{tr,td,br,span,div,ul,li,button,a,i} = React.DOM

ShareNetworkItem = ({
  shareNetwork,
  handleShow,
  handleDelete,
  handleEdit,
  handleShareNetworkSecurityServices,
  network,
  subnet
})->

  tr {className: ('updating' if shareNetwork.isDeleting)},
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
                a { href: '#', onClick: ((e) -> e.preventDefault(); handleShareNetworkSecurityServices(shareNetwork.id)) }, 'Security Servieces'


shared_filesystem_storage.ShareNetworkItem = ShareNetworkItem
