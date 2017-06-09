{ tr,td,button,i } = React.DOM

shared_filesystem_storage.ShareNetworkSecurityServiceItem = ({handleDelete, shareNetworkSecurityService}) ->
  tr className: ('updating' if shareNetworkSecurityService.isDeleting),
    td null, shareNetworkSecurityService.name
    td null, shareNetworkSecurityService.id
    td null, shareNetworkSecurityService.type
    td null, shareNetworkSecurityService.status
    td className: 'snug',
      button className: 'btn btn-danger btn-sm', onClick: ((e) -> e.preventDefault(); handleDelete(rule.id)),
        i className: 'fa fa-minus'
