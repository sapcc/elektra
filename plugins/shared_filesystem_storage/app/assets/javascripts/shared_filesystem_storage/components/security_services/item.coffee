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

    td null, securityService.type
    td null, securityService.status
    td className: "snug",
      if securityService.permissions.delete or securityService.permissions.update
        div { className: 'btn-group' },
          button { className: 'btn btn-default btn-sm dropdown-toggle', type: 'button', 'data-toggle': 'dropdown', 'aria-expanded': true},
            span {className: 'fa fa-cog' }

          ul { className: 'dropdown-menu dropdown-menu-right', role: "menu" },
            if securityService.permissions.delete
              li null,
                a { href: '#', onClick: ((e) -> e.preventDefault(); handleDelete(securityService.id))}, 'Delete'
            if securityService.permissions.update
              li null,
                a { href: '#', onClick: ((e) -> e.preventDefault(); handleEdit(securityService)) }, 'Edit'


shared_filesystem_storage.SecurityServiceItem = SecurityServiceItem
