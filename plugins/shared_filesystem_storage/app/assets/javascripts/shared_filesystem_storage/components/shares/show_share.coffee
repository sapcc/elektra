{ div,form,textarea,b,table,tbody,tr,th,td,h4,h3,label,span,button,abbr,select,option,ul,li } = React.DOM
{ReactAccordion} = shared_filesystem_storage
 
shared_filesystem_storage.ShowShare = React.createClass 
  getInitialState: ->
    share: {}
    
  dataRow: (label,value) ->
    div className: "row form_row",
      div className: "col-sm-2",
        b className: "pull-right", label
      div className: "col-sm-10", value  
    
  open: (share) -> 
    unless share.export_locations
      @props.loadExportLocations(share.id)
         
    @setState share: share
    @refs.modal.open()
  close: () -> @refs.modal.close()
  handleClose: () -> null
  
  render: ->
    export_locations = (@props.share and @props.share.export_locations) || @props.shareExportLocations[@state.share.id] 
    
    React.createElement shared_filesystem_storage.Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'Share'
      
      if @state.share.id
        tabs = {
          "Overview": div null,
            table className: 'table no-borders',
              tbody null,
                tr null,
                  th style: {width: '30%'}, "Name"
                  td null, @state.share.name
                tr null,
                  th null, "ID"
                  td null, @state.share.id
                tr null,  
                  th null, "Status"
                  td null, @state.share.status
                
                tr null,  
                  th null, "Export Locations"
                  td null,
                    if export_locations
                      for location in export_locations
                        div(key: location.id, location.path)

                    else
                      span className: 'spinner'          
                                

                tr null,  
                  th null, 'Visibility'
                  td null, (if @state.share.is_public then 'public' else 'private')
                tr null,  
                  th null, 'Availability zone'
                  td null, @state.share.availability_zone
                  

                tr null,
                  th style: {width: '30%'}, "Size"
                  td null, @state.share.size+' GiB'
                tr null,
                  th null, "Protocol"
                  td null, @state.share.share_proto
                tr null,  
                  th null, "Share Type"
                  td null, @state.share.share_type
                tr null,  
                  th null, "Share network"
                  td null, @state.share.share_network_id
                tr null,  
                  th null, 'Created At'
                  td null, @state.share.created_at
                tr null,  
                  th null, 'Host'
                  td null, @state.share.host
        }
        
        if @state.share.metadata and Object.keys(@state.share.metadata).length>0     
          tabs['Metadata'] = table className: 'table',
            tbody null,
              for name,value of @state.share.metadata
                tr null,
                  th style: {width: '30%'}, name
                  td null, value
                  
        div className: 'modal-body',  
          React.createElement shared_filesystem_storage.ReactTabs, tabs: tabs

      div className: 'modal-footer',
        button role: 'close', type: 'button', className: 'btn btn-default', onClick: @close, 'Close'
        
        