#= require kubernetes/components/clusters/item

# import
{ div, span, label, select, option, input, i, table, thead, tbody, tr, th, td, button } = React.DOM
{ connect } = ReactRedux
{ ClusterItem, createCluster } = kubernetes


Clusters = ({
  clusters,
  isFetching,
  error
}) ->

  div null,
    div className: 'toolbar toolbar-controlcenter',
      div className: 'main-control-buttons',
        button className: "btn btn-primary", onClick: ((e) -> e.preventDefault(); handleClusterCreate()),
          "Create Cluster"

      # div className: 'inputwrapper',
      #   if attributeValues[filterType] && attributeValues[filterType].length > 0
      #     select name: 'filterTerm', className: 'form-control filter-term', value: filterTerm, onChange: ((e) -> handleFilterTermChange(e.target.value, 0)),
      #       option value: '', 'Select'
      #       for attribute in attributeValues[filterType]
      #         option value: attribute, key: "filterTerm_#{attribute}", attribute
      #   else
      #     input name: 'filterTerm', className: 'form-control filter-term', value: filterTerm, placeholder: 'Enter lookup value', disabled: ReactHelpers.isEmpty(filterType) || isFetchingAttributeValues, onChange: ((e) -> handleFilterTermChange(e.target.value, 500))
      # span className: 'toolbar-input-divider'



    table className: 'table',
      thead null,
        tr null,
          th null, 'Cluster'
          th null, 'Status'
          th className: 'snug', ''

      tbody null,
        if error
          tr null,
            td colSpan: '3',
              error
        else
          if clusters
            for cluster in clusters
              React.createElement ClusterItem, cluster: cluster, key: cluster.name

          else
            tr null,
              td colSpan: '3',
                'No clusters found'

        if isFetching
          tr null,
            td colSpan: '3',
              span className: 'spinner'



Clusters = connect(
  (state) ->
    clusters: state.clusters.items

  (dispatch) ->
    handleClusterCreate:  () -> dispatch(createCluster())




)(Clusters)


# export
kubernetes.ClusterList = Clusters
