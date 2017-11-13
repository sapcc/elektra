{tr,td,br,span,div,ul,li,button,a} = React.DOM


SnapshotItem = ({
  snapshot,
  share,
  handleShow,
  handleDelete,
  handleEdit
}) ->

  tr {className: ('updating' if (snapshot.isFetching or snapshot.isDeleting))},
    td null,
      a href:"#", onClick: ((e) -> e.preventDefault(); handleShow(snapshot)), snapshot.name
      br null
      span className: 'info-text', snapshot.id
    td null,
      if share
        div null,
          share.name
          br null
          span className: 'info-text', snapshot.share_id
      else
        snapshot.share_id

    td null, (snapshot.size || 0) + ' GB'
    td null, snapshot.status
    td className: "snug",
      if snapshot.permissions.delete or snapshot.permissions.update
        div className: 'btn-group',
          button className: 'btn btn-default btn-sm dropdown-toggle', type: 'button', 'data-toggle': 'dropdown', 'aria-expanded': true,
            span className: 'fa fa-cog'

          ul className: 'dropdown-menu dropdown-menu-right', role: "menu",
            if snapshot.permissions.delete
              li null,
                a { href: '#', onClick: ((e) -> e.preventDefault(); handleDelete(snapshot.id))}, 'Delete'
            if snapshot.permissions.update
              li null,
                a { href: '#', onClick: ((e) -> e.preventDefault(); handleEdit(snapshot)) }, 'Edit'

shared_filesystem_storage.SnapshotItem = SnapshotItem
