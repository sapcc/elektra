import "./events.coffee"
import { connect } from "react-redux"

import {  
  openEditClusterDialog, 
  requestDeleteCluster,
  loadCluster, 
  getCredentials, 
  getSetupInfo, 
  startPollingCluster, 
  stopPollingCluster, 
  loadClusterEvents 
} from "../../actions"

import ClusterEvents from "./events.coffee"

class Cluster extends React.Component 

  UNSAFE_componentWillReceiveProps: (nextProps) ->
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
    cluster.status.phase == 'Running' && cluster.spec.version == cluster.status.apiserverVersion

  nodePoolsReady: (cluster) ->
    # not ready if number of nodepools in spec and status don't match
    if cluster.status.nodePools.length != cluster.spec.nodePools.length
      return false

    # return ready only if all state values of all nodepools match the configured size
    ready = true
    for nodePool in cluster.spec.nodePools
      ready = @nodePoolReady(nodePool, cluster)
      if !ready
        break
    ready


  nodePoolReady: (nodePool, cluster) ->
    ready = true
    nodePoolStatus = @nodePoolStatus(cluster, nodePool.name)

    for k,v of nodePoolStatus
      if /healthy|running|schedulable/.test(k)
        if v != nodePoolStatus.size
          ready = false
          break
    ready

  # find spec size for pool with given name
  nodePoolSpecSize: (cluster, poolName) ->
    pool = (cluster.spec.nodePools.filter (i) -> i.name is poolName)[0]
    pool.size

  # find status for pool with given name
  nodePoolStatus: (cluster, poolName) ->
    pool = (cluster.status.nodePools.filter (i) -> i.name is poolName)[0]



  render: ->
    {cluster, kubernikusBaseUrl, handleEditCluster, handleClusterDelete, handleGetCredentials, handleGetSetupInfo, handlePollingStart, handlePollingStop} = @props
    disabled = cluster.isTerminating or cluster.status.phase == 'Terminating'

    React.createElement 'tbody', className: ('item-disabled' if disabled),
      React.createElement 'tr', null,
        React.createElement 'td',  null,
          cluster.name
        React.createElement 'td',  null,
          React.createElement 'div',  null,
            React.createElement 'strong',  null, cluster.status.phase
            unless @clusterReady(cluster)
              React.createElement 'span', className: 'spinner'
          
          if cluster.status.apiserverVersion
            React.createElement 'div',  null,
              "Version: #{cluster.status.apiserverVersion}"
              
          React.createElement 'div',  className: 'info-text', cluster.status.message 
        React.createElement 'td',  className: 'nodepool-spec',
          for nodePool in cluster.spec.nodePools
            nodePoolStatus = @nodePoolStatus(cluster, nodePool.name)

            React.createElement 'div',  className: 'nodepool', key: nodePool.name,
              React.createElement 'div',  className: 'nodepool-info',
                React.createElement 'div',  null,
                  React.createElement 'strong',  null, nodePool.name
                React.createElement 'div',  null, nodePool.availabilityZone
                React.createElement 'div',  null,
                  React.createElement 'span', className: 'info-text', nodePool.flavor
                React.createElement 'div',  null,
                  "size: #{nodePool.size}"

              React.createElement 'div',  className: 'nodepool-info',
                if nodePoolStatus?
                  for k,v of nodePoolStatus
                    unless k == 'name' || k == 'size'
                      React.createElement 'div',  key: "status-#{k}",
                        React.createElement 'strong',  null, "#{k}: "
                        "#{v}/#{nodePool.size}"
                        if v != nodePool.size
                          React.createElement 'span', className: 'spinner'

                else
                  React.createElement 'div',  null,
                    'Loading '
                    React.createElement 'span', className: 'spinner'



        React.createElement 'td',  className: 'vertical-buttons',
          React.createElement 'button',  className: 'btn btn-sm btn-primary btn-icon-text', disabled: disabled, onClick: ((e) -> e.preventDefault(); handleEditCluster(cluster)),
            React.createElement 'i', className: 'fa fa-fw fa-pencil'
            'Edit Cluster'

          React.createElement 'button',  className: 'btn btn-sm btn-default btn-icon-text', disabled: disabled, onClick: ((e) -> e.preventDefault(); handleGetCredentials(cluster.name)),
            React.createElement 'i', className: 'fa fa-fw fa-download'
            'Download Credentials'

          React.createElement 'button',  className: 'btn btn-sm btn-default btn-icon-text', disabled: disabled, onClick: ((e) -> e.preventDefault(); handleGetSetupInfo(cluster.name, kubernikusBaseUrl)),
            React.createElement 'i', className: 'fa fa-fw fa-wrench'
            'Setup'

          cluster.status.dashboard && 
            React.createElement 'a', className: 'btn btn-sm btn-default btn-icon-text', disabled: disabled, href: "#{cluster.status.dashboard}", target: "_blank",
              React.createElement 'i', className: 'fa fa-fw fa-dashboard'
              'Kubernetes Dashboard'


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
export default Cluster
