#= require components/form_helpers


{ div,form,input,textarea,h4, h5,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{  } = kubernetes


SetupInfo = ({
  close,
  setupData
}) ->

  div null,
    div className: 'modal-body',
      p null, 'Here comes your setup data'
      setupData




    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'


EditCluster = connect(
  (state) ->
    setupData: state.setupData

  (dispatch) ->


)(SetupInfo)

kubernetes.SetupInfoModal = ReactModal.Wrapper('Setup Information', SetupInfo,
  large: true,
  closeButton: false,
  static: true
)
