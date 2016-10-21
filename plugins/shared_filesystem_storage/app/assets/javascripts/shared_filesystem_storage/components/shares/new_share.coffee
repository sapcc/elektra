{ div,form,textarea,h4,label,span,button,abbr,select,option } = React.DOM
 
shared_filesystem_storage.NewShare = React.createClass 
  getInitialState: () ->
    loading: false
    share: {}
    errors: null
    
  open: () -> @refs.modal.open()
  close: () -> @refs.modal.close()
  handleClose: () -> @setState @getInitialState()
  
  handleChange: (name,value)->
    share = @state.share
    share[name]=value
    @setState share: share
  
  handleSubmit: (share) ->  
    @setState loading: true
    @props.ajax.post 'shares',
      data: { share: share } 
      success: (data, textStatus, jqXHR) =>
        @props.handleCreateShare data
        @setState @getInitialState()
        @close()
      error: ( jqXHR, textStatus, errorThrown)  =>
        @setState errors: jqXHR.responseJSON
      complete: () =>
        @setState loading: false
  
  handleClickNewShareNetwork: () ->
    @close()
    @props.setActiveTab('share_networks')
        
  render: ->
    { Modal, ShareForm } = shared_filesystem_storage
    
    React.createElement Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'New Share'
      
      React.createElement ShareForm, 
        share: @state.share
        share_types: @props.share_types
        availability_zones: @props.availability_zones
        shareNetworks: @props.shareNetworks
        handleSubmit: @handleSubmit
        handleCancel: @close
        buttonLabel: 'Create'
        loading: @state.loading
        handleClickNewShareNetwork: @handleClickNewShareNetwork
        errors: @state.errors

        