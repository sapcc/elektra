#= require ./modal

{ div, h4, i, p, button } = React.DOM
ReactInfoDialog = ({title,message,close}) ->
  div null,
    div className: 'modal-body',
      if title
        h4 null,
          i className: "fa fa-fw fa-info-circle", null
          title
      if message
        div null,
          i className: "fa fa-fw fa-info-circle", null unless title
          message if message

    div className: 'modal-footer',
      button
        role: 'cancel',
        type: 'button',
        className: 'btn btn-default',
        onClick: close,
        'Close'

@ReactInfoDialog = ReactModal.Wrapper('Info', ReactInfoDialog,
  closeButton: false,
  static: true
)
