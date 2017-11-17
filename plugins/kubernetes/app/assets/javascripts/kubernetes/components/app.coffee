#= require kubernetes/components/clusters/new
#= require kubernetes/components/clusters/edit
#= require kubernetes/components/clusters/list
#= require kubernetes/components/clusters/credentials
#= require kubernetes/components/clusters/setup
#= require components/dialogs



{ div, h4, p, a, ul, li } = React.DOM
{ connect } = ReactRedux
{ ClusterList, NewClusterModal, EditClusterModal, SetupInfoModal } = kubernetes

modalComponents =
  'NEW_CLUSTER':      NewClusterModal
  'EDIT_CLUSTER':     EditClusterModal
  'SETUP_INFO':       SetupInfoModal
  'CONFIRM':          ReactConfirmDialog
  'INFO':             ReactInfoDialog
  'ERROR':            ReactErrorDialog


App = ({permissions, kubernikusBaseUrl}) ->

  div null,
    React.createElement ClusterList, kubernikusBaseUrl: kubernikusBaseUrl
    React.createElement ReactModal.Container('modals', modalComponents)



kubernetes.App = connect(

)(App)
