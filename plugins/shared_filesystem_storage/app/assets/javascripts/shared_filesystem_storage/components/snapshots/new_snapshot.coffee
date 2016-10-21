{ div,form,textarea,h4,label,span,button,abbr,select,option } = React.DOM
 
shared_filesystem_storage.NewSnapshot = React.createClass 
  getInitialState: () ->
    loading: false
    snapshot: {}
    errors: null
    
  open: (share) -> 
    @props.loadSnapshots() unless @props.snapshots
    
    snapshot = @state.snapshot
    snapshot.share_id=share.id
    @setState snapshot:snapshot
    @refs.modal.open()
    
  close: () -> @refs.modal.close()
  handleClose: () -> @setState @getInitialState()
  
  handleChange: (name,value)->
    snapshot = @state.snapshot
    snapshot[name]=value
    @setState snapshot: snapshot
  
  handleSubmit: (snapshot) ->  
    @setState loading: true
    @props.ajax.post "snapshots",
      data: { snapshot: snapshot } 
      success: (data, textStatus, jqXHR) =>
        @props.handleCreateSnapshot data
        @setState @getInitialState()
        @close()
      error: ( jqXHR, textStatus, errorThrown)  =>
        @setState errors: jqXHR.responseJSON
      complete: () =>
        @setState loading: false
  
  render: ->
    { Modal, SnapshotForm } = shared_filesystem_storage
    
    React.createElement Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'New Snapshot'
      
      if @props.snapshots
        React.createElement SnapshotForm, 
          snapshot: @state.snapshot
          handleSubmit: @handleSubmit
          handleCancel: @close
          buttonLabel: 'Create'
          loading: @state.loading
          errors: @state.errors
        
      else
        div null,
          span className: 'spinner', null
          'Loading...'    

        