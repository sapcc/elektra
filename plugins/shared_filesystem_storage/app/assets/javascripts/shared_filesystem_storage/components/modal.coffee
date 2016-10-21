{div,button,span,h4} = React.DOM

shared_filesystem_storage.Modal = React.createClass
  getDefaultProps: ->
    large: true

  componentDidMount: ->
    $(@refs.modal).on 'shown.bs.modal', @props.onShown
    $(@refs.modal).on 'hidden.bs.modal', @props.onHidden

  open: () -> $(@refs.modal).modal('show')
  close: () -> $(@refs.modal).modal('hide')

  render: ->
    div null,
      div { className: "modal fade", tabIndex: -1, role: "dialog", ref: 'modal', 'data-backdrop': 'static'},
        div { className: "modal-dialog #{'modal-lg' if @props.large}", role: "document" },
          div { className: "modal-content"}, @props.children


shared_filesystem_storage.Modal.SubmitButton = React.createClass
  getDefaultProps: -> 
    type: 'submit'
    className: 'btn-primary'
    label: 'Save'
    disable_with: 'Please wait...'
    loading: false
    disabled: true
  render: -> React.DOM.button 
    type: "submit", 
    onClick: @props.onSubmit, 
    className: "btn #{@props.className}", 
    disabled: if (@props.loading or @props.disabled) then true else false
    if @props.loading then @props.disable_with else @props.label 