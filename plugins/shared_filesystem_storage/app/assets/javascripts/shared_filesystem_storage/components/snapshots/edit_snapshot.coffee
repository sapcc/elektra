{div,form,textarea,h4,label,span,button,abbr,select,option} = React.DOM

shared_filesystem_storage.EditSnapshot = React.createClass 
  getInitialState: () ->
    loading: false
    snapshot: {}
    errors: null

  open: (snapshot) ->
    @setState snapshot: jQuery.extend({}, snapshot), () => @refs.modal.open()
  
  handleChange: (name,value)->
    snapshot = @state.snapshot
    snapshot[name]=value
    @setState snapshot: snapshot
    
  close: () -> @refs.modal.close()  
  handleClose: () -> @getInitialState()
    
  handleSubmit: (snapshot) ->
    @setState loading: true
    @props.ajax.put "/snapshots/#{snapshot.id}",
      data: { snapshot: snapshot } 
      success: (data, textStatus, jqXHR) =>
        @props.handleUpdateSnapshot snapshot, data
        @setState @getInitialState()
        @refs.modal.close() 
      error: ( jqXHR, textStatus, errorThrown)  =>
        @setState errors: jqXHR.responseJSON   
        
      complete: () =>
        @setState loading: false

  render: ->
    { Modal,SnapshotForm } = shared_filesystem_storage
    
    React.createElement Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'Edit Snapshot'
      
      React.createElement SnapshotForm, 
        snapshot: @state.snapshot
        loading: @state.loading
        handleSubmit: @handleSubmit
        handleCancel: @close
        buttonLabel: 'Update'
        errors: @state.errors

