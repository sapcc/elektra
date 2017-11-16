{ tr,td,button,i } = React.DOM

shared_filesystem_storage.ShareNetworkSecurityServiceItem = ({handleDelete, securityService}) ->
  tr className: ('updating' if securityService.isDeleting),
    td null, securityService.name
    td null, securityService.id
    td null, securityService.type
    td null, securityService.status
    td className: 'snug',
      button className: 'btn btn-danger btn-sm', onClick: ((e) -> e.preventDefault(); handleDelete(securityService.id)),
        i className: 'fa fa-minus'
