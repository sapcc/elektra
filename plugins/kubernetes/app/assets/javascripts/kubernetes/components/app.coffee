#= require kubernetes/components/clusters/new
#= require kubernetes/components/clusters/list
#= require components/dialogs


{ div, h4, p, a, ul, li } = React.DOM
{ connect } = ReactRedux
{ ClusterList, NewClusterModal } = kubernetes

modalComponents =
  'NEW_CLUSTER': NewClusterModal

App = ({permissions: permissions}) ->

  div null,
    div className: "bs-callout bs-callout-info bs-callout-emphasize",
      h4 null, "Welcome to our Kubernetes-as-a-Service offering"
      p null, "Within minutes you will be able to setup a VM based Kubernetes cluster. Your cluster is fully-managed and allows auto-updating masters and auto-repairing nodes. Identity management and access control is integrated with Converged Cloud."


    React.createElement ClusterList
    React.createElement ReactModal.Container('modals', modalComponents)



kubernetes.App = connect(

)(App)
