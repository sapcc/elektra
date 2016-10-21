{div,form,textarea,h4,label,span,button,abbr,select,option} = React.DOM

shared_filesystem_storage.EditShareNetwork = React.createClass 
  getInitialState: () ->
    loading: false
    shareNetwork: {}
    errors: null

  open: (shareNetwork) ->
    @setState shareNetwork: jQuery.extend({}, shareNetwork), () => @refs.modal.open()
  
  close: () -> @refs.modal.close()  
  handleClose: () -> @getInitialState()
  
  handleChange: (name,value)->
    shareNetwork = @state.shareNetwork
    shareNetwork[name]=value
    @setState shareNetwork: shareNetwork
    
  handleSubmit: () ->
    @setState loading: true
    @props.ajax.put "share-networks/#{@state.shareNetwork.id}",
      data: { share_network: @state.shareNetwork } 
      success: (data, textStatus, jqXHR) =>
        @props.handleUpdateShareNetwork @state.shareNetwork, data
        @setState @getInitialState()
        @refs.modal.close()  
      error: ( jqXHR, textStatus, errorThrown)  =>
        @setState errors: jqXHR.responseJSON  
      complete: () =>
        @setState loading: false

  render: ->
    { Modal,ShareNetworkForm } = shared_filesystem_storage
    
    React.createElement Modal, ref: 'modal', onHidden: @handleClose,
      div className: 'modal-header',    
        button type: "button", className: "close", "aria-label": "Close", onClick: @close,
          span "aria-hidden": "true", 'x'
        h4 className: 'modal-title', 'Edit Shared Network'
      
      React.createElement ShareNetworkForm, 
        shareNetwork: @state.shareNetwork
        loading: @state.loading
        networks: @props.networks
        subnets: @props.subnets
        loadSubnets: @props.loadSubnets
        handleSubmit: @handleSubmit
        handleCancel: @close
        handleChange: @handleChange
        buttonLabel: 'Update'
        errors: @state.errors

