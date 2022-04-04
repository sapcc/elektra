#= require ./modal
{ div, h4, p, i, button } = React.DOM
ReactConfirmDialog = ({title,message,confirmCallback,cancelCallback,close}) ->
  div null,
    div className: 'modal-body',
      if title
        h4 null,
          i className: "confirm-icon fa fa-fw fa-exclamation-triangle", null
          title
      if message
        p null,
          i  className: "confirm-icon fa fa-fw fa-exclamation-triangle", null unless title
          message if message

    div className: 'modal-footer',
      button
        role: 'cancel',
        type: 'button',
        className: 'btn btn-default',
        onClick: (() -> close(); if cancelCallback then cancelCallback()),
        'No'
      button
        role: 'confirm',
        type: 'button',
        className: 'btn btn-primary',
        onClick: (() -> close(); if confirmCallback then confirmCallback()),
        'Yes'

@ReactConfirmDialog = ReactModal.Wrapper('Please Confirm', ReactConfirmDialog,
  closeButton: false,
  static: true
)
