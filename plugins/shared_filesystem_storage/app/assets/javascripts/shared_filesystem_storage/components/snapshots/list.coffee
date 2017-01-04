#= require shared_filesystem_storage/components/snapshots/item

{ connect } = ReactRedux
{ div, table, thead, tbody, tr, th, td, span } = React.DOM
{
  SnapshotItem,
  fetchSnapshotsIfNeeded,
  openNewSnapshotDialog,
  openDeleteSnapshotDialog,
  openShowSnapshotDialog,
  openEditSnapshotDialog
} = shared_filesystem_storage

SnapshotList = React.createClass
  componentDidMount: ->
    @props.loadSnapshotsOnce() if @props.active

  componentWillReceiveProps: (nextProps) ->
    @props.loadSnapshotsOnce() if nextProps.active

  share: (snapshot)->
    return 'loading' if @props.shares.isFetching
    @props.shares.items.find((share)-> share.id==snapshot.share_id)

  render: ->
    if @props.isFetching
      div null,
        span className: 'spinner', null
        'Loading...'
    else
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
            React.createElement SnapshotItem,
              key: snapshot.id,
              snapshot: snapshot
              share: @share(snapshot)
              handleShow: @props.handleShow
              handleDelete: @props.handleDelete
              handleEdit: @props.handleEdit

SnapshotList = connect(
  (state) ->
    snapshots: state.snapshots.items
    shares: state.shares
    isFetching: state.snapshots.isFetching
  (dispatch) ->
    loadSnapshotsOnce: () -> dispatch(fetchSnapshotsIfNeeded())
    handleNewSnapshot: () -> dispatch(openNewSnapshotDialog())
    handleShow: (snapshot) -> dispatch(openShowSnapshotDialog(snapshot))
    handleDelete: (snapshotId) -> dispatch(openDeleteSnapshotDialog(snapshotId))
    handleEdit: (snapshot) -> dispatch(openEditSnapshotDialog(snapshot))
)(SnapshotList)

shared_filesystem_storage.SnapshotList = SnapshotList
