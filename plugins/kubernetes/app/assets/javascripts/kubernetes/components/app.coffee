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
    div className: 'bs-callout bs-callout-info bs-callout-emphasize',
      h4 null, "Welcome to our Kubernetes-as-a-Service offering"
      p null, "Within minutes you will be able to setup a VM based Kubernetes cluster. Your cluster is fully-managed and allows auto-updating masters and auto-repairing nodes. Identity management and access control is integrated with Converged Cloud."


    React.createElement ClusterList, kubernikusBaseUrl: kubernikusBaseUrl
    React.createElement ReactModal.Container('modals', modalComponents)



kubernetes.App = connect(

)(App)
