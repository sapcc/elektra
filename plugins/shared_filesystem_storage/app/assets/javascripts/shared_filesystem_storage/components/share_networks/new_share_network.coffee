{ div,form,textarea,h4,label,span,button,abbr,select,option } = React.DOM
 
shared_filesystem_storage.NewShareNetwork = React.createClass 
  displayName: 'NewShareNetwork'
  getInitialState: () ->
    loading: false
    shareNetwork: {}
    errors: null
    
  open: () -> @refs.modal.open()
  close: () -> @refs.modal.close()
  handleClose: () -> @setState @getInitialState()
  
  handleChange: (name,value)->
    shareNetwork = @state.shareNetwork
    shareNetwork[name]=value
    @setState shareNetwork: shareNetwork
    
  handleSubmit: ->  
    @setState loading: true
    @props.ajax.post "share-networks",
      data: { share_network: @state.shareNetwork } 
      success: (data, textStatus, jqXHR) =>
        @props.handleCreateShareNetwork data
        @setState @getInitialState()
        @close()
      error: ( jqXHR, textStatus, errorThrown)  =>
        @setState errors: jqXHR.responseJSON  
      complete: () =>
        @setState loading: false
  

  render: ->
    { Modal, ShareNetworkForm } = shared_filesystem_storage
    
    React.createElement Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'New Shared Network'
      
      React.createElement ShareNetworkForm, 
        networks: @props.networks
        subnets: @props.subnets
        loadSubnets: @props.loadSubnets
        handleSubmit: @handleSubmit
        handleCancel: @close
        handleChange: @handleChange
        buttonLabel: 'Create'
        mode: 'create'
        loading: @state.loading
        shareNetwork: @state.shareNetwork
        errors: @state.errors       