#= require components/form_helpers


{ div,button, p, br, code, pre, a, h5, h4, ul, li} = React.DOM
{ connect } = ReactRedux
{ } = kubernetes


SetupInfo = ({
  close,
  setupData,
  kubernikusBaseUrl
}) ->

  div null,
    div className: 'modal-body',
      h4 null, 'Download Binaries'
      p null, 'Download the file matching your operating system, save it somewhere in your path and make it executable.'

      for bin in setupData.binaries
        div key: bin.name,
          h5 null, "#{bin.name}:"
          for link in bin.links
            ul className: 'content-list', key: link.platform,
              li null,
                a target: '_blank', href: link.link, "Download for #{link.platform}"

      br null

      h4 null, 'Execute Setup Command'
      p null,
        'Copy the below setup command and execute it in your terminal.'
      pre className: 'snippet', ref: ((el) ->$(el).initSnippetCopyToClipboard()),
        code null,
          setupData.setupCommand



    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'


SetupInfo = connect(
  (state) ->
    setupData: state.clusters.setupData
    kubernikusBaseUrl: state.clusters.kubernikusBaseUrl



)(SetupInfo)

kubernetes.SetupInfoModal = ReactModal.Wrapper('Setup Information', SetupInfo,
  large: true,
  closeButton: false,
  static: true
)
