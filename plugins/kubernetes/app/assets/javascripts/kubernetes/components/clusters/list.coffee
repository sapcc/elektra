#= require kubernetes/components/clusters/item

# import
{ div, span, label, select, option, input, i, table, thead, tbody, tr, th, td, button } = React.DOM
{ connect } = ReactRedux
{ ClusterItem, openNewClusterDialog, fetchClusters } = kubernetes


Clusters = React.createClass

  componentDidMount: ->
    @props.loadClusters()

  render: ->

    div null,
      div className: 'toolbar toolbar-controlcenter',
        div className: 'main-control-buttons',
          button className: "btn btn-primary", onClick: ((e) => e.preventDefault(); @props.handleNewCluster()),
            "Create Cluster"


      table className: 'table',
        thead null,
          tr null,
            th null, 'Cluster'
            th null, 'Status'
            th className: 'snug', ''

        tbody null,
          if @props.isFetching
            tr null,
              td colSpan: '3',
                span className: 'spinner'
          else

            if @props.error
              tr null,
                td colSpan: '3',
                  error
            else
              if @props.clusters && @props.clusters.length
                for cluster in @props.clusters
                  React.createElement ClusterItem, cluster: cluster, key: cluster.name

              else
                tr null,
                  td colSpan: '3',
                    'No clusters found'



Clusters = connect(
  (state) ->
    clusters:   state.clusters.items
    isFetching: state.clusters.isFetching
    error:      state.clusters.error

  (dispatch) ->
    handleNewCluster: () -> dispatch(openNewClusterDialog())
    loadClusters:     () -> dispatch(fetchClusters())

)(Clusters)


# export
kubernetes.ClusterList = Clusters
