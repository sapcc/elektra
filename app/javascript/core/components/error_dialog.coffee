import "./modal"

ReactErrorDialog = ({title,message,close}) ->
  React.createElement 'div',  null,
    React.createElement 'div',  className: 'modal-body',
      if title
        React.createElement 'h4',  className: 'text-danger',
          React.createElement 'i',  className: "fa fa-fw fa-exclamation-triangle", null
          title
      if message
        React.createElement 'div',  className: "text-danger",
          React.createElement 'i',  className: "fa fa-fw fa-exclamation-triangle", null unless title
          message if message

    React.createElement 'div',  className: 'modal-footer',
      React.createElement 'button', 
        role: 'cancel',
        type: 'button',
        className: 'btn btn-default',
        onClick: close,
        'Close'

window.ReactErrorDialog = ReactModal.Wrapper('Error', ReactErrorDialog,
  closeButton: false,
  static: false
)
