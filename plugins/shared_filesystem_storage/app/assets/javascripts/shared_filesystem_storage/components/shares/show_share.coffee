{ div,form,textarea,b,table,tbody,tr,th,td,h4,h3,label,span,button,abbr,select,option,ul,li } = React.DOM
 
shared_filesystem_storage.ShowShare = React.createClass 
  getInitialState: ->
    share: {}
    
  dataRow: (label,value) ->
    div className: "row form_row",
      div className: "col-sm-2",
        b className: "pull-right", label
      div className: "col-sm-10", value  
    
  open: (share) -> 
    @setState share: share
    @refs.modal.open()
  close: () -> @refs.modal.close()
  handleClose: () -> null

  render: ->
    React.createElement shared_filesystem_storage.Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'Share Overview'
      
      if @state.share.id
        div className: 'modal-body',
          h4 className: 'info-text', 'Info'
          @dataRow "Name", @state.share.name
          @dataRow "ID", @state.share.id
          @dataRow "Status", @state.share.status
          @dataRow "Export Locations", (div(key: link.href, link.href) for link in @state.share.links)
          @dataRow 'Visibility', (if @state.share.is_public then 'public' else 'private')
          @dataRow 'Availability zone', @state.share.availability_zone
                
          h4 className: 'info-text', 'Specs'
          @dataRow "Size", @state.share.size+' GiB'
          @dataRow "Protocol", @state.share.share_proto
          @dataRow "Share Type", @state.share.share_type_name
          @dataRow "Share network", @state.share.share_network_id
          @dataRow "Created At", @state.share.created_at
          @dataRow "Host", @state.share.host

          if @state.share.metadata and Object.keys(@state.share.metadata).length>0
            div null,
              h4 className: 'info-text', 'Metadata'
              @dataRow name, value for name,value of @state.share.metadata

      div className: 'modal-footer',
        button role: 'close', type: 'button', className: 'btn btn-default', onClick: @close, 'Close'
        
        