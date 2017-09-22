{ div, button, span, a, tbody, tr, td, ul, li, i, br, p, strong} = React.DOM
{ connect } = ReactRedux
{ requestDeleteCluster,loadCluster, getCredentials } = kubernetes


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
    {cluster, handleClusterDelete, handleGetCredentials} = @props

    tr null,
      td null,
        cluster.name
      td null,
        cluster.status.kluster
      td null,
        for nodePool in cluster.spec.nodePools
          p key: nodePool.name,
            strong null, nodePool.name
            br null
            span className: 'info-text', nodePool.flavor
            br null
            'Ready: '
            cluster.status.nodePools[ReactHelpers.findIndexInArray(cluster.status.nodePools, nodePool.name, 'name')].ready
            '/'
            nodePool.size

      td className: 'vertical-buttons',
        button className: 'btn btn-sm btn-primary', onClick: ((e) -> e.preventDefault(); handleGetCredentials(cluster.name)),
          i className: 'fa fa-fw fa-download'
          'Download Credentials'

        button className: 'btn btn-sm btn-default hover-danger', onClick: ((e) -> e.preventDefault(); handleClusterDelete(cluster.name)),
          i className: 'fa fa-fw fa-trash-o'
          'Delete Cluster'


        # div className: "btn-group",
        #   button className: "btn btn-default btn-sm dropdown-toggle", "data-toggle": "dropdown", type: "button",
        #     span className: "fa fa-cog"
        #   ul className: "dropdown-menu dropdown-menu-right dropdown-menu-with-icons", role: "menu",
        #     li null,
        #       a href: "#", onClick: ((e) -> e.preventDefault(); handleGetCredentials(cluster.name)),
        #         i className: 'fa fa-download'
        #         'Download Credentials'
        #
        #     li className: 'divider'
        #     li null,
        #       a href: "#", onClick: ((e) -> e.preventDefault(); handleClusterDelete(cluster.name)),
        #         i className: 'fa fa-trash-o'
        #         'Delete Cluster'



Cluster = connect(
  (state, ownProps) ->
    for item in state.clusters.items
      if ownProps.cluster.name == item.name
        cluster = item
        break

    cluster: cluster
  (dispatch) ->
    handleClusterDelete:    (clusterName) -> dispatch(requestDeleteCluster(clusterName))
    handleGetCredentials:   (clusterName) -> dispatch(getCredentials(clusterName))
    reloadCluster:          (clusterName) -> dispatch(loadCluster(clusterName))

)(Cluster)


# export
kubernetes.ClusterItem = Cluster
