import "./modal"

ReactConfirmDialog = ({title,message,confirmCallback,cancelCallback,close}) ->
  React.createElement 'div',  null,
    React.createElement 'div',  className: 'modal-body',
      if title
        React.createElement 'h4',  null,
          React.createElement 'i',  className: "confirm-icon fa fa-fw fa-exclamation-triangle", null
          title
      if message
        React.createElement 'p', null,
          React.createElement 'i',   className: "confirm-icon fa fa-fw fa-exclamation-triangle", null unless title
          message if message

    React.createElement 'div',  className: 'modal-footer',
      React.createElement 'button', 
        role: 'cancel',
        type: 'button',
        className: 'btn btn-default',
        onClick: (() -> close(); if cancelCallback then cancelCallback()),
        'No'
      React.createElement 'button', 
        role: 'confirm',
        type: 'button',
        className: 'btn btn-primary',
        onClick: (() -> close(); if confirmCallback then confirmCallback()),
        'Yes'

window.ReactConfirmDialog = ReactModal.Wrapper('Please Confirm', ReactConfirmDialog,
  closeButton: false,
  static: true
)
