{tr,td,br,span,div,ul,li,button,a} = React.DOM


SecurityServiceItem = ({
  securityService,
  handleShow,
  handleDelete,
  handleEdit
}) ->

  tr {className: ('updating' if (securityService.isFetching or securityService.isDeleting))},
    td null,
      a href:"#", onClick: ((e) -> e.preventDefault(); handleShow(securityService)), securityService.name
      br null
      span className: 'info-text', securityService.id

    td null, securityService.description
    td null, securityService.type
    td null, securityService.status
    td className: "snug",
      null

shared_filesystem_storage.SecurityServiceItem = SecurityServiceItem
