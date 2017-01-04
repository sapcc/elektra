#= require react/tabs

{ div, span, br, button, a, table, tbody, thead, tr, th, td } = React.DOM

ShowSnapshot = ({snapshot,close}) ->
  div null,
    div className: 'modal-body',
      table className: 'table no-borders',
        tbody null,
          tr null,
            th null, "Name"
            td null, snapshot.name
          tr null,
            th null, "ID"
            td null, snapshot.id
          tr null,
            th null, "Status"
            td null, snapshot.status
          tr null,
            th null, "Description"
            td null, snapshot.description
          tr null,
            th null, "Share ID"
            td null, snapshot.share_id
          tr null,
            th null, "Share Size"
            td null, snapshot.share_size+' GiB'
          tr null,
            th null, "Protocol"
            td null, snapshot.share_proto
          tr null,
            th null, 'Created At'
            td null, snapshot.created_at

    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'

shared_filesystem_storage.ShowSnapshotModal = ReactModal.Wrapper('Snapshot Details', ShowSnapshot, large:true)
