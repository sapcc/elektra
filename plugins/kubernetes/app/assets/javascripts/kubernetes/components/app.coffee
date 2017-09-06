#= require kubernetes/components/clusters/list
#= require kubernetes/components/clusters/new
#= require components/dialogs


{ div, h4, p, a, ul, li } = React.DOM
{ connect } = ReactRedux
{ ClusterList, fetchClusters, NewClusterModal } = kubernetes

modalComponents =
  'NEW_CLUSTER': NewClusterModal

App = React.createClass
  componentDidMount: ->
    @props.loadClusters()

  render: () ->

    div null,
      div className: "bs-callout bs-callout-info bs-callout-emphasize",
        h4 null, "Welcome to our Kubernetes-as-a-Service offering"
        p null, "Within minutes you will be able to setup a VM based Kubernetes cluster. Your cluster is fully-managed and allows auto-updating masters and auto-repairing nodes. Identity management and access control is integrated with Converged Cloud."


      React.createElement ClusterList,
        clusters: @props.clusters.items,
        isFetching: @props.isFetching,
        loadClusters: @props.loadClusters


      React.createElement ReactModal.Container('modals', modalComponents)




kubernetes.App = connect(
  (state) ->
    clusters:   state.clusters.items
    isFetching: state.isFetching

  (dispatch) ->
    loadClusters:         () -> dispatch(fetchClusters())

)(App)
