#= require kubernetes/components/clusters/events


{ div, button, span, a, tbody, tr, td, ul, li, i, br, p, strong, h5} = React.DOM
{ connect } = ReactRedux
{ ClusterEvents, openEditClusterDialog, requestDeleteCluster,loadCluster, getCredentials, getSetupInfo, startPollingCluster, stopPollingCluster, loadClusterEvents } = kubernetes


Cluster = React.createClass

  componentWillReceiveProps: (nextProps) ->
    # stop polling if both cluster and nodepool states are "ready"
    if @clusterReady(nextProps.cluster) && @nodePoolsReady(nextProps.cluster)
      @stopPolling()
    else if !nextProps.cluster.isPolling
      @startPolling()

  componentDidMount:()->
    @startPolling() if !@clusterReady(@props.cluster) || !@nodePoolsReady(@props.cluster)

  componentWillUnmount: () ->
    # stop polling on unmounting
    @stopPolling()

  startPolling: ()->
    @props.handlePollingStart(@props.cluster.name)
    clearInterval(@polling)
    @polling = setInterval((() => @props.reloadCluster(@props.cluster.name)), 10000)

  stopPolling: () ->
    @props.handlePollingStop(@props.cluster.name)
    clearInterval(@polling)


  clusterReady: (cluster) ->
    cluster.status.phase == 'Running'

  nodePoolsReady: (cluster) ->
    # not ready if number of nodepools in spec and status don't match
    if cluster.status.nodePools.count != cluster.spec.nodePools.count
      return false

    # return ready only if all state values of all nodepools match the configured size
    ready = true
    for nodePool in cluster.status.nodePools
      ready = @nodePoolReady(nodePool, cluster)
    ready


  nodePoolReady: (nodePool, cluster) ->
    ready = true
    specSize = @nodePoolSpecSize(cluster, nodePool.name)
    for k,v of nodePool
      unless k == 'name' || k == 'size'
        if v != specSize
          ready = false
          break
    ready

  # find spec size for pool with given name
  nodePoolSpecSize: (cluster, poolName) ->
    pool = (cluster.spec.nodePools.filter (i) -> i.name is poolName)[0]
    pool.size



  render: ->
    {cluster, kubernikusBaseUrl, handleEditCluster, handleClusterDelete, handleGetCredentials, handleGetSetupInfo, handlePollingStart, handlePollingStop} = @props
    disabled = cluster.isTerminating or cluster.status.phase == 'Terminating'

    tbody className: ('item-disabled' if disabled),
      tr null,
        td null,
          cluster.name
        td null,
          strong null, cluster.status.phase
          unless @clusterReady(cluster)
            span className: 'spinner'
          br null
          span className: 'info-text', cluster.status.message
        td className: 'nodepool-spec',
          for nodePool in cluster.spec.nodePools
            div className: 'nodepool-info', key: nodePool.name,
              div null,
                strong null, nodePool.name
              # div null, nodePool.availabilityZone
              div null,
                span className: 'info-text', nodePool.flavor
              div null,
                "size: #{nodePool.size}"
        td className: 'nodepool-status',
          for nodePoolStatus in cluster.status.nodePools
            specSize = @nodePoolSpecSize(cluster, nodePoolStatus.name)
            div className: 'nodepool-info', key: "status-#{nodePoolStatus.name}",
              statusAvailable = false
              for k,v of nodePoolStatus
                unless k == 'name' || k == 'size'
                  statusAvailable = true
                  div key: k,
                    strong null, "#{k}: "
                    "#{v}/#{specSize}"
                    if v != specSize
                      span className: 'spinner'

              unless statusAvailable
                span className: 'spinner'




        td className: 'vertical-buttons',
          button className: 'btn btn-sm btn-primary btn-icon-text', disabled: disabled, onClick: ((e) -> e.preventDefault(); handleEditCluster(cluster)),
            i className: 'fa fa-fw fa-pencil'
            'Edit Cluster'

          button className: 'btn btn-sm btn-default btn-icon-text', disabled: disabled, onClick: ((e) -> e.preventDefault(); handleGetCredentials(cluster.name)),
            i className: 'fa fa-fw fa-download'
            'Download Credentials'

          button className: 'btn btn-sm btn-default btn-icon-text', disabled: disabled, onClick: ((e) -> e.preventDefault(); handleGetSetupInfo(cluster.name, kubernikusBaseUrl)),
            i className: 'fa fa-fw fa-wrench'
            'Setup'


      React.createElement ClusterEvents, cluster: cluster





Cluster = connect(
  (state, ownProps) ->
    for item in state.clusters.items
      if ownProps.cluster.name == item.name
        cluster = item
        break

    cluster: cluster

  (dispatch) ->
    handleEditCluster:        (cluster)                         -> dispatch(openEditClusterDialog(cluster))
    handleClusterDelete:      (clusterName)                     -> dispatch(requestDeleteCluster(clusterName))
    handleGetCredentials:     (clusterName)                     -> dispatch(getCredentials(clusterName))
    handleGetSetupInfo:       (clusterName, kubernikusBaseUrl)  -> dispatch(getSetupInfo(clusterName, kubernikusBaseUrl))
    reloadCluster:            (clusterName)                     -> dispatch(loadCluster(clusterName))
    handlePollingStart:       (clusterName)                     -> dispatch(startPollingCluster(clusterName))
    handlePollingStop:        (clusterName)                     -> dispatch(stopPollingCluster(clusterName))



)(Cluster)


# export
kubernetes.ClusterItem = Cluster
