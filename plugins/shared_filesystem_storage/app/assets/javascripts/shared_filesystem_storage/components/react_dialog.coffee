{div, button, h4, label, i, span} = React.DOM

shared_filesystem_storage.ReactDialog = React.createClass
  
  statics:
    # Static method show. This method adds a modal window to DOM and removes it after the window was closed.  
    # Options:
    #  description (null)
    # Callbacks:
    #  then (callbacks for confirmed state)
    #  fail (callbacks for rejected state)
    # Example: shared_filesystem_storage.ReactInfoDialog.show('Error', {description: 'Can not delete' }).then(function(){alert('OK')}).fail(function(){alert('CANCEL')}) 
    show: (message, options = {type: 'info'}) ->
      props = $.extend({message: message}, options)
      wrapper = document.body.appendChild(document.createElement('div'))
      component = ReactDOM.render(React.createElement(shared_filesystem_storage.ReactDialog, props), wrapper)
      cleanup = ->
        ReactDOM.unmountComponentAtNode(wrapper)
        wrapper.remove()
      component.promise.always(cleanup).promise()

  close: ->
    # close modal window
    @refs.modal.close()
    @promise.resolve()
    
  # this method is called if modal window was closed outside this component  
  handleClose: ->
    @promise.resolve()
    
  componentDidMount: ->
    @promise = new $.Deferred()
    @refs.closeButton.focus()
    @refs.modal.open()


  render: ->
    switch @props.type
      when 'info' 
        icon = i(className: "fa fa-fw fa-info", null)
        colorClass = ''
      when 'error' 
        icon = i(className: "fa fa-fw fa-exclamation-triangle", null)
        colorClass = 'text-danger'
      else 
        icon = null
        colorClass = ''
        
    React.createElement shared_filesystem_storage.Modal, ref: 'modal', large: false, onHidden: @handleClose,
      div className: 'modal-header',    
        h4 className: 'modal-title', 
          span null, 
            icon
            @props.message
      if @props.description 
        div className: "modal-body #{colorClass}", @props.description 
        
      div className: 'modal-footer',
        button role: 'close', type: 'button', className: 'btn btn-default', ref: 'closeButton', onClick: @close, 'Close'


class shared_filesystem_storage.ReactInfoDialog
  @show: (message, options={}) -> shared_filesystem_storage.ReactDialog.show(message, $.extend({type: 'info'}, options))
    
class shared_filesystem_storage.ReactErrorDialog
  @show: (message, options={}) -> shared_filesystem_storage.ReactDialog.show(message,$.extend({type: 'error'}, options))    
                   