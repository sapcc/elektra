{ div,table,thead,tr,th,tbody,td,span,button } = React.DOM

shared_filesystem_storage.Snapshots = React.createClass
  componentDidMount: () ->
    # load content on adding this component to the DOM
    @props.loadSnapshots() unless @props.snapshots

  # open modal window with form for edit share.
  editSnapshot: (snapshot) ->
    @refs.editSnapshotModal.open(snapshot)
                
  render: ->
    unless @props.snapshots
      div null,
        span className: 'spinner', null
        'Loading...'
    else 
      div null, 
        # Modal Overlay for Editing Share
        React.createElement shared_filesystem_storage.EditSnapshot,
          ref: 'editSnapshotModal',
          ajax: @props.ajax,
          handleUpdateSnapshot: @props.updateSnapshot
            
        table {className: 'table snapshots'},
          thead null,
            tr null,
              th null, 'Name'
              th null, 'Source'
              th null, 'Size'
              th null, 'Status'
              th null, ''
          tbody null,
            if @props.snapshots.length==0
              tr null,
                td { colSpan: 5 }, 'No Snapshots found.'
            for snapshot in @props.snapshots
              React.createElement shared_filesystem_storage.Snapshot, 
                key: snapshot.id
                ajax: @props.ajax
                snapshot: snapshot
                share: @props.getShare(snapshot.share_id)
                handleDeleteSnapshot: @props.deleteSnapshot                   
                handleEditSnapshot: @editSnapshot
