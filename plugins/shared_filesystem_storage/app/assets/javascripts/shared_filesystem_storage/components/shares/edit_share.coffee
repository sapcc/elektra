{div,form,textarea,h4,label,span,button,abbr,select,option} = React.DOM

shared_filesystem_storage.EditShare = React.createClass 
  getInitialState: () ->
    loading: false
    share: {}
    errors: null

  open: (share) ->
    @setState share: jQuery.extend({}, share), () => @refs.modal.open()
  
  handleChange: (name,value)->
    share = @state.share
    share[name]=value
    @setState share: share
    
  close: () -> @refs.modal.close()  
  handleClose: () -> @getInitialState()
    
  handleSubmit: (share) ->
    @setState share: share
    @props.ajax.put "/shares/#{share.id}",
      data: { share: share } 
      success: (data, textStatus, jqXHR) =>
        @props.handleUpdateShare share, data
        @setState @getInitialState()
        @refs.modal.close() 
      error: ( jqXHR, textStatus, errorThrown)  =>
        @setState errors: jqXHR.responseJSON   
        
      complete: () =>
        @setState loading: false

  handleClickNewShareNetwork: () ->
    @close()
    @props.setActiveTab('share_networks')
    
  render: ->
    { Modal,ShareForm } = shared_filesystem_storage
    
    React.createElement Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'Edit Share'
      
      React.createElement ShareForm, 
        share: @state.share
        loading: @state.loading
        shareNetworks: @props.shareNetworks
        handleSubmit: @handleSubmit
        handleCancel: @close
        buttonLabel: 'Update'
        handleClickNewShareNetwork: @handleClickNewShareNetwork
        errors: @state.errors

