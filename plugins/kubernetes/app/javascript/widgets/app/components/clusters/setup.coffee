import "core/components/form_helpers.coffee"
import { connect } from "react-redux"

{ } = kubernetes

SetupInfo = ({
  close,
  setupData,
  kubernikusBaseUrl
}) ->

  React.createElement 'div',  null,
    React.createElement 'div',  className: 'modal-body',
      React.createElement 'h4',  null, 'Download Binaries'
      React.createElement 'p',  null, 'Download the file matching your operating system, save it somewhere in your path and make it executable.'

      for bin in setupData.binaries
        React.createElement 'div',  key: bin.name,
          React.createElement 'h5',  null, "#{bin.name}:"
          for link in bin.links
            React.createElement 'ul',  className: 'content-list', key: link.platform,
              React.createElement 'li',  null,
                React.createElement 'a',  target: '_blank', href: link.link, "Download for #{link.platform}"

      React.createElement 'br',  null

      React.createElement 'h4',  null, 'Execute Setup Command'
      React.createElement 'p',  null,
        'Copy the below setup command and execute it in your terminal.'
      React.createElement 'pre',  className: 'snippet', ref: ((el) ->$(el).initSnippetCopyToClipboard()),
        React.createElement 'code',  null,
          setupData.setupCommand



    React.createElement 'div',  className: 'modal-footer',
      React.createElement 'button', role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'


SetupInfo = connect(
  (state) ->
    setupData: state.clusters.setupData
    kubernikusBaseUrl: state.clusters.kubernikusBaseUrl



)(SetupInfo)

SetupInfoModal = ReactModal.Wrapper('Setup Information', SetupInfo,
  large: true,
  closeButton: false,
  static: true
)

export default SetupInfoModal
