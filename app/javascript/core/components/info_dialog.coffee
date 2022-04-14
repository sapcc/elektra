import "./modal"

ReactInfoDialog = ({title,message,close}) ->
  React.createElement 'div',  null,
    React.createElement 'div',  className: 'modal-body',
      if title
        React.createElement 'h4', null,
          React.createElement 'i',  className: "fa fa-fw fa-info-circle", null
          title
      if message
        React.createElement 'div',  null,
          React.createElement 'i',  className: "fa fa-fw fa-info-circle", null unless title
          message if message

    React.createElement 'div',  className: 'modal-footer',
      React.createElement 'button', 
        role: 'cancel',
        type: 'button',
        className: 'btn btn-default',
        onClick: close,
        'Close'

window.ReactInfoDialog = ReactModal.Wrapper('Info', ReactInfoDialog,
  closeButton: false,
  static: true
)
