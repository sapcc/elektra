/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react"
import { connect } from "react-redux"

import {
  openEditClusterDialog,
  requestDeleteCluster,
  loadCluster,
  getCredentials,
  getSetupInfo,
  startPollingCluster,
  stopPollingCluster,
} from "../../actions"

import ClusterEvents from "./events"

class Cluster extends React.Component {
  UNSAFE_componentWillReceiveProps(nextProps) {
    // stop polling if both cluster and nodepool states are "ready"
    if (
      this.clusterReady(nextProps.cluster) &&
      this.nodePoolsReady(nextProps.cluster)
    ) {
      return this.stopPolling()
    } else if (!nextProps.cluster.isPolling) {
      return this.startPolling()
    }
  }

  componentDidMount() {
    if (
      !this.clusterReady(this.props.cluster) ||
      !this.nodePoolsReady(this.props.cluster)
    ) {
      return this.startPolling()
    }
  }

  componentWillUnmount() {
    // stop polling on unmounting
    return this.stopPolling()
  }

  startPolling() {
    this.props.handlePollingStart(this.props.cluster.name)
    clearInterval(this.polling)
    return (this.polling = setInterval(
      () => this.props.reloadCluster(this.props.cluster.name),
      10000
    ))
  }

  stopPolling() {
    this.props.handlePollingStop(this.props.cluster.name)
    return clearInterval(this.polling)
  }

  clusterReady(cluster) {
    return (
      cluster.status.phase === "Running" &&
      cluster.spec.version === cluster.status.apiserverVersion
    )
  }

  nodePoolsReady(cluster) {
    // not ready if number of nodepools in spec and status don't match
    if (cluster.status.nodePools.length !== cluster.spec.nodePools.length) {
      return false
    }

    // return ready only if all state values of all nodepools match the configured size
    let ready = true
    for (var nodePool of Array.from(cluster.spec.nodePools)) {
      ready = this.nodePoolReady(nodePool, cluster)
      if (!ready) {
        break
      }
    }
    return ready
  }

  nodePoolReady(nodePool, cluster) {
    let ready = true
    const nodePoolStatus = this.nodePoolStatus(cluster, nodePool.name)

    for (var k in nodePoolStatus) {
      var v = nodePoolStatus[k]
      if (/healthy|running|schedulable/.test(k)) {
        if (v !== nodePoolStatus.size) {
          ready = false
          break
        }
      }
    }
    return ready
  }

  // find spec size for pool with given name
  nodePoolSpecSize(cluster, poolName) {
    const pool = cluster.spec.nodePools.filter((i) => i.name === poolName)[0]
    return pool.size
  }

  // find status for pool with given name
  nodePoolStatus(cluster, poolName) {
    let pool
    return (pool = cluster.status.nodePools.filter(
      (i) => i.name === poolName
    )[0])
  }

  render() {
    const {
      cluster,
      kubernikusBaseUrl,
      handleEditCluster,
      handleClusterDelete,
      handleGetCredentials,
      handleGetSetupInfo,
      handlePollingStart,
      handlePollingStop,
    } = this.props
    const disabled =
      cluster.isTerminating ||
      cluster.status.phase === "Terminating" ||
      cluster.status.phase === "Pending" ||
      cluster.status.phase === "Creating"

    return React.createElement(
      "tbody",
      { className: disabled ? "item-disabled" : undefined },
      React.createElement(
        "tr",
        null,
        <td>{cluster.name}</td>,
        <td>
          <div>
            <strong>{cluster.status.phase}</strong>
            {!this.clusterReady(cluster) ? (
              <span className="spinner" />
            ) : undefined}
          </div>
          {cluster.status.apiserverVersion ? (
            <div>{`Version: ${cluster.status.apiserverVersion}`}</div>
          ) : undefined}
          <div className="info-text">{cluster.status.message}</div>
        </td>,
        <td className="nodepool-spec">
          {(() => {
            const result = []
            for (var nodePool of Array.from(cluster.spec.nodePools)) {
              var nodePoolStatus = this.nodePoolStatus(cluster, nodePool.name)

              result.push(
                <div className="nodepool" key={nodePool.name}>
                  <div className="nodepool-info">
                    <div>
                      <strong>{nodePool.name}</strong>
                    </div>
                    <div>{nodePool.availabilityZone}</div>
                    <div>
                      <span className="info-text">{nodePool.flavor}</span>
                    </div>
                    <div>{`size: ${nodePool.size}`}</div>
                  </div>
                  <div className="nodepool-info">
                    {nodePoolStatus != null ? (
                      (() => {
                        const result1 = []
                        for (var k in nodePoolStatus) {
                          var v = nodePoolStatus[k]
                          if (k !== "name" && k !== "size") {
                            result1.push(
                              <div key={`status-${k}`}>
                                <strong>{`${k}: `}</strong>
                                {`${v}/${nodePool.size}`}
                                {v !== nodePool.size ? (
                                  <span className="spinner" />
                                ) : undefined}
                              </div>
                            )
                          } else {
                            result1.push(undefined)
                          }
                        }
                        return result1
                      })()
                    ) : (
                      <div>
                        Loading <span className="spinner" />
                      </div>
                    )}
                  </div>
                </div>
              )
            }
            return result
          })()}
        </td>,
        React.createElement(
          "td",
          { className: "vertical-buttons" },
          React.createElement(
            "button",
            {
              className: "btn btn-sm btn-primary btn-icon-text",
              disabled,
              onClick(e) {
                e.preventDefault()
                return handleEditCluster(cluster)
              },
            },
            <i className="fa fa-fw fa-pencil" />,
            "Edit Cluster"
          ),
          React.createElement(
            "button",
            {
              className: "btn btn-sm btn-default btn-icon-text",
              disabled,
              onClick(e) {
                e.preventDefault()
                return handleGetCredentials(cluster.name)
              },
            },
            <i className="fa fa-fw fa-download" />,
            "Download Credentials"
          ),
          React.createElement(
            "button",
            {
              className: "btn btn-sm btn-default btn-icon-text",
              disabled,
              onClick(e) {
                e.preventDefault()
                return handleGetSetupInfo(cluster.name, kubernikusBaseUrl)
              },
            },
            <i className="fa fa-fw fa-wrench" />,
            "Setup"
          ),
          cluster.spec.dashboard && cluster.status.dashboard && (
            <a
              className="btn btn-sm btn-default btn-icon-text"
              disabled={disabled}
              href={`${cluster.status.dashboard}`}
              target="_blank"
              rel="noreferrer"
            >
              <i className="fa fa-fw fa-dashboard" />
              Kubernetes Dashboard
            </a>
          )
        )
      ),
      <ClusterEvents cluster={cluster} />
    )
  }
}

export default connect(
  function (state, ownProps) {
    let cluster
    for (var item of Array.from(state.clusters.items)) {
      if (ownProps.cluster.name === item.name) {
        cluster = item
        break
      }
    }

    return { cluster }
  },
  (dispatch) => ({
    handleEditCluster(cluster) {
      return dispatch(openEditClusterDialog(cluster))
    },
    handleClusterDelete(clusterName) {
      return dispatch(requestDeleteCluster(clusterName))
    },
    handleGetCredentials(clusterName) {
      return dispatch(getCredentials(clusterName))
    },
    handleGetSetupInfo(clusterName, kubernikusBaseUrl) {
      return dispatch(getSetupInfo(clusterName, kubernikusBaseUrl))
    },
    reloadCluster(clusterName) {
      return dispatch(loadCluster(clusterName))
    },
    handlePollingStart(clusterName) {
      return dispatch(startPollingCluster(clusterName))
    },
    handlePollingStop(clusterName) {
      return dispatch(stopPollingCluster(clusterName))
    },
  })
)(Cluster)
