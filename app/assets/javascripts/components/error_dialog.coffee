#= require ./modal

{ div, h4, i, p, button } = React.DOM
ReactErrorDialog = ({title,message,close}) ->
  div null,
    div className: 'modal-body',
      if title
        h4 className: 'text-danger',
          i className: "fa fa-fw fa-exclamation-triangle", null
          title
      if message
        div className: "text-danger",
          i className: "fa fa-fw fa-exclamation-triangle", null unless title
          message if message

    div className: 'modal-footer',
      button
        role: 'cancel',
        type: 'button',
        className: 'btn btn-default',
        onClick: close,
        'Close'

@ReactErrorDialog = ReactModal.Wrapper('Error', ReactErrorDialog,
  closeButton: false,
  static: false
)
