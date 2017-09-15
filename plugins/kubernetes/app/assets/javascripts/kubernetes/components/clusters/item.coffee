{ div, button, span, a, tr, td, ul, li} = React.DOM
{ connect } = ReactRedux
{ requestDeleteCluster } = kubernetes


Cluster = ({cluster, handleClusterDelete}) ->
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
  (state) ->
    {}
  (dispatch) ->
    handleClusterDelete: (clusterName) -> dispatch(requestDeleteCluster(clusterName))

)(Cluster)


# export
kubernetes.ClusterItem = Cluster
