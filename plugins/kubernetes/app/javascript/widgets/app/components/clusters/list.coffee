# import
import { connect } from "react-redux"
import ClusterItem from "./item.coffee"
import { fetchClusters, openNewClusterDialog } from "../../actions"

class Clusters extends React.Component 

  componentDidMount: ->
    @props.loadClusters()

  render: ->
    {flashError, isFetching, clusters, handleNewCluster, error, kubernikusBaseUrl} = @props

    React.createElement 'div', null,
      if flashError? or error?
        React.createElement 'div', className: 'alert alert-error alert-dismissible',
          React.createElement 'button', className: 'close', type: 'button', 'data-dismiss': 'alert',
            React.createElement 'span', null,
              '\u00D7' # &times;
          flashError
          error

      unless isFetching || error? || (clusters? && clusters.length > 0)
        React.createElement 'div', className: 'toolbar toolbar-controlcenter',
          React.createElement 'div', className: 'main-control-buttons',
            React.createElement 'button', className: "btn btn-primary", onClick: ((e) => e.preventDefault(); handleNewCluster()),
              "Create Cluster"


      React.createElement 'table', className: 'table',
        React.createElement 'thead', null,
          React.createElement 'tr', null,
            React.createElement 'th', null, 'Cluster'
            React.createElement 'th', null, 'Status'
            React.createElement 'th', className: 'pool-info-column', 'Nodepools'
            React.createElement 'th', className: 'snug'



        if isFetching
          React.createElement 'tbody', null,
            React.createElement 'tr', null,
              React.createElement 'td', colSpan: '5',
                React.createElement 'span', className: 'spinner'
        else
          if clusters? && clusters.length
            for cluster in clusters
              React.createElement ClusterItem, cluster: cluster, key: cluster.name, kubernikusBaseUrl: kubernikusBaseUrl

          else
            React.createElement 'tbody', null,
              React.createElement 'tr', null,
                React.createElement 'td', colSpan: '5',
                  if error?
                    'Could not retrieve clusters'
                  else
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
export default Clusters
