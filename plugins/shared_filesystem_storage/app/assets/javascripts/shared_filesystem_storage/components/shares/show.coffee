#= require react/tabs

{ div, span, br, button, a, table, tbody, thead, tr, th, td } = React.DOM
{ fetchShareExportLocations } = shared_filesystem_storage
{ connect } = ReactRedux

ShowShare = React.createClass
  componentWillMount: ->
    unless @props.share.export_locations
      @props.dispatch(fetchShareExportLocations(@props.shareId))

  tabs: () ->
    share = @props.share
    result = [{
      name: "Overview"
      uid: 'overview'
      content: div null,
        table className: 'table no-borders',
          tbody null,
            tr null,
              th style: {width: '30%'}, "Name"
              td null, share.name
            tr null,
              th null, "ID"
              td null, share.id
            tr null,
              th null, "Status"
              td null, share.status

            tr null,
              th null, "Export Locations"
              td null,
                if share.export_locations
                  for location in share.export_locations
                    div(key: location.id, location.path)

                else
                  span className: 'spinner'

            tr null,
              th null, 'Availability zone'
              td null, share.availability_zone


            tr null,
              th style: {width: '30%'}, "Size"
              td null, share.size+' GiB'
            tr null,
              th null, "Protocol"
              td null, share.share_proto
            tr null,
              th null, "Share Type"
              td null, share.share_type
            tr null,
              th null, "Share network"
              td null, share.share_network_id
            tr null,
              th null, 'Created At'
              td null, share.created_at
            tr null,
              th null, 'Host'
              td null, share.host
    }]

    if share.metadata and Object.keys(share.metadata).length>0
      result.push {
        name: 'Metadata'
        uid: 'metadata'
        content: table className: 'table',
          tbody null,
            for name,value of share.metadata
              tr null,
                th style: {width: '30%'}, name
                td null, value
      }
    result

  render: ->
    div null,
      div className: 'modal-body', React.createElement ReactTabs, tabsConfig: @tabs()

      div className: 'modal-footer',
        button role: 'close', type: 'button', className: 'btn btn-default', onClick: @props.close, 'Close'

ShowShare = connect(
  (state,ownProps) ->
    share: state.shares.items.find((item) -> ownProps.shareId==item.id),
  (dispatch) ->
    loadExportLocations: (shareId) -> dispatch(fetchShareExportLocations(shareId))
)(ShowShare)

shared_filesystem_storage.ShowShareModal = ReactModal.Wrapper('Share Details', ShowShare, large:true)
