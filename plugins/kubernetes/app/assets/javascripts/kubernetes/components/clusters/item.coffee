{ div, button, span, a, tbody, tr, td, ul, li, i, br, p, strong} = React.DOM
{ connect } = ReactRedux
{ openEditClusterDialog, requestDeleteCluster,loadCluster, getCredentials } = kubernetes


Cluster = React.createClass

  componentWillReceiveProps: (nextProps) ->
    # stop polling if status has changed from creating to something else
    @stopPolling() if nextProps.cluster.status.kluster.state == 'Ready'

  componentDidMount:()->
    @startPolling() if @props.cluster.status.kluster.state != 'Ready'

  componentWillUnmount: () ->
    # stop polling on unmounting
    @stopPolling()

  startPolling: ()->
    @polling = setInterval((() => @props.reloadCluster(@props.cluster.name)), 10000)

  stopPolling: () ->
    clearInterval(@polling)

  render: ->
    {cluster, handleEditCluster, handleClusterDelete, handleGetCredentials} = @props

    tr null,
      td null,
        cluster.name
      td null,
        strong null, cluster.status.kluster.state
        br null
        span className: 'info-text', cluster.status.kluster.message
      td className: 'nodepool-info',
        for nodePool in cluster.spec.nodePools
          div key: nodePool.name,
            div null,
              strong null, nodePool.name
            div null,
              span className: 'info-text', nodePool.flavor
            div null,
              "size: #{nodePool.size}"
      td className: 'nodepool-info',
        for nodePoolStatus in cluster.status.nodePools
          div key: nodePool.name,
            for k,v of nodePoolStatus
              unless k == 'name' || k == 'size'
                div key: k,
                  strong null, "#{k}: "
                  "#{v}/#{nodePoolStatus.size}"




      td className: 'vertical-buttons',
        console.log("cluster: ", cluster)
        button className: 'btn btn-sm btn-primary', onClick: ((e) -> e.preventDefault(); handleEditCluster(cluster)),
          i className: 'fa fa-fw fa-pencil'
          'Edit Cluster'

        button className: 'btn btn-sm btn-primary', onClick: ((e) -> e.preventDefault(); handleGetCredentials(cluster.name)),
          i className: 'fa fa-fw fa-download'
          'Download Credentials'

        button className: 'btn btn-sm btn-default hover-danger', onClick: ((e) -> e.preventDefault(); handleClusterDelete(cluster.name)),
          i className: 'fa fa-fw fa-trash-o'
          'Delete Cluster'





Cluster = connect(
  (state, ownProps) ->
    for item in state.clusters.items
      if ownProps.cluster.name == item.name
        cluster = item
        break

    cluster: cluster
  (dispatch) ->
    handleEditCluster:      (cluster)     -> dispatch(openEditClusterDialog(cluster))
    handleClusterDelete:    (clusterName) -> dispatch(requestDeleteCluster(clusterName))
    handleGetCredentials:   (clusterName) -> dispatch(getCredentials(clusterName))
    reloadCluster:          (clusterName) -> dispatch(loadCluster(clusterName))

)(Cluster)


# export
kubernetes.ClusterItem = Cluster
