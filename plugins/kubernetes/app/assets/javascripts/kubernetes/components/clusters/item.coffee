{ div, button, span, a, tr, td, ul, li} = React.DOM
{ connect } = ReactRedux
{ requestDeleteCluster,loadCluster } = kubernetes


Cluster = React.createClass

  componentWillReceiveProps: (nextProps) ->
    # stop polling if status has changed from creating to something else
    @stopPolling() if nextProps.cluster.status.kluster == 'Ready'

  componentDidMount:()->
    @startPolling() if @props.cluster.status.kluster != 'Ready'

  componentWillUnmount: () ->
    # stop polling on unmounting
    @stopPolling()

  startPolling: ()->
    @polling = setInterval((() => @props.reloadCluster(@props.cluster.name)), 10000)

  stopPolling: () ->
    clearInterval(@polling)

  render: ->
    {cluster, handleClusterDelete} = @props

    tr null,
      td null,
        cluster.name
      td null,
        cluster.status.kluster
      td className: "snug",
        div className: "btn-group",
          button className: "btn btn-default btn-sm dropdown-toggle", "data-toggle": "dropdown", type: "button",
            span className: "fa fa-cog"
          ul className: "dropdown-menu dropdown-menu-right", role: "menu",
            li null,
              a href: "#", onClick: ((e) -> e.preventDefault(); handleClusterDelete(cluster.name)),
                'Delete Cluster'



Cluster = connect(
  (state, ownProps) ->
    for item in state.clusters.items
      if ownProps.cluster.name == item.name
        cluster = item
        break

    cluster: cluster
  (dispatch) ->
    handleClusterDelete:  (clusterName) -> dispatch(requestDeleteCluster(clusterName))
    reloadCluster:        (clusterName) -> dispatch(loadCluster(clusterName))

)(Cluster)


# export
kubernetes.ClusterItem = Cluster
