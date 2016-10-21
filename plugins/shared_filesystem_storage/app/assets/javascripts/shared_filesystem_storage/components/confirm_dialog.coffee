Promise = $.Deferred
{div, button, h4, label, input, i} = React.DOM

shared_filesystem_storage.ConfirmDialog = React.createClass
  
  statics:
    # Static method ask. This method adds a modal window to DOM and removes it after the window was closed.  
    # Options:
    #  description (null)
    #  confirmLabel ('OK')
    #  abortLabel ('Cancel')
    #  validationTerm (if given then the user has to confirm by entering a validation term)
    # Callbacks:
    #  then (callbacks for confirmed state)
    #  fail (callbacks for rejected state)
    # Example: shared_filesystem_storage.ConfirmDialog.ask('Are you sure?', {description: 'really?' }).then(function(){alert('OK')}).fail(function(){alert('CANCEL')}) 
    ask: (message, options = {}) ->
      props = $.extend({message: message}, options)
      wrapper = document.body.appendChild(document.createElement('div'))
      component = ReactDOM.render(React.createElement(shared_filesystem_storage.ConfirmDialog, props), wrapper)
      cleanup = ->
        ReactDOM.unmountComponentAtNode(wrapper)
        wrapper.remove()
      component.promise.always(cleanup).promise()

  getInitialState: ->
    disabled: if @props.validationTerm then true else false
    
  getDefaultProps: ->
    message: 'Are you sure?'
    confirmLabel: 'OK'
    abortLabel: 'Cancel'

  abort: ->
    # close modal window
    @refs.modal.close()
    # call "fail" callbacks (see ask method)
    @promise.reject()

  confirm: ->
    # close modal window
    @refs.modal.close()
    # call "then" callbacks (see ask method)
    @promise.resolve()
    
  # this method is called if modal window was closed outside this component  
  handleClose: ->
    @promise.reject()
    
  componentDidMount: ->
    @promise = new Promise()
    @refs.confirm.focus()
    @refs.modal.open()
    
  validate: (e) ->
    return true unless @props.validationTerm 
    @setState disabled: e.target.value!=@props.validationTerm 

  render: ->
    React.createElement shared_filesystem_storage.Modal, ref: 'modal', large: false, onHidden: @handleClose,
      div className: 'modal-header',    
        h4 className: 'modal-title', 
          i className: "confirm-icon fa fa-fw fa-exclamation-triangle", null
          @props.message
      if @props.description or @props.validationTerm
        div className: 'modal-body', 
          if @props.description 
            @props.description 
          if @props.validationTerm
            div className: "confirm-term form-group string required",
              label className: 'string required', "Please confirm #{@props.validationTerm}",
              input type: 'text', onChange: @validate
        
      div className: 'modal-footer',
        button role: 'abort', type: 'button', className: 'btn btn-default', onClick: @abort, @props.abortLabel
        button role: 'confirm', type: 'button', className: 'btn btn-primary', ref: 'confirm', disabled: @state.disabled, onClick: @confirm, @props.confirmLabel

             