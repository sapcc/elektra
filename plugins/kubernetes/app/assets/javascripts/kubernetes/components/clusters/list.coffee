#= require kubernetes/components/clusters/item

# import
{ div, span, label, select, option, input, i, table, thead, tbody, tr, th, td, button } = React.DOM
{ connect } = ReactRedux
{ ClusterItem, openNewClusterDialog, fetchClusters } = kubernetes



Clusters = React.createClass

  componentDidMount: ->
    @props.loadClusters()

  render: ->
    {flashError, isFetching, clusters, handleNewCluster, error} = @props

    div null,
      if flashError or error
        div className: 'alert alert-error alert-dismissible',
          button className: 'close', type: 'button', 'data-dismiss': 'alert',
            span null,
              '\u00D7' # &times;
          flashError
          error

      unless clusters && clusters.length
        div className: 'toolbar toolbar-controlcenter',
          div className: 'main-control-buttons',
            button className: "btn btn-primary", onClick: ((e) => e.preventDefault(); handleNewCluster()),
              "Create Cluster"


      table className: 'table',
        thead null,
          tr null,
            th null, 'Cluster'
            th null, 'Status'
            th className: 'pool-info-column', 'Nodepools'
            th className: 'pool-info-column', 'Nodepool Status'
            th className: 'snug'


        tbody null,
          if isFetching
            tr null,
              td colSpan: '5',
                span className: 'spinner'
          else
            if clusters && clusters.length
              for cluster in clusters
                React.createElement ClusterItem, cluster: cluster, key: cluster.name

            else
              tr null,
                td colSpan: '5',
                  'No clusters found'



Clusters = connect(
  (state) ->
    clusters:   state.clusters.items
    isFetching: state.clusters.isFetching
    error:      state.clusters.error
    flashError: state.clusters.flashError

  (dispatch) ->
    handleNewCluster: () -> dispatch(openNewClusterDialog())
    loadClusters:     () -> dispatch(fetchClusters())

)(Clusters)


# export
kubernetes.ClusterList = Clusters
