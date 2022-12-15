/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react"
import { connect } from "react-redux"
import { loadClusterEvents } from "../../actions"
import moment from "moment"

class Events extends React.Component {
  componentDidMount() {
    this.props.handleLoadClusterEvents(this.props.cluster.name)
    return this.startPollingClusterEvents()
  }

  startPollingClusterEvents() {
    clearInterval(this.pollingEvents)
    return (this.pollingEvents = setInterval(
      () => this.props.handleLoadClusterEvents(this.props.cluster.name),
      60000
    ))
  }

  render() {
    const { cluster, events, handleLoadClusterEvents } = this.props

    if (events.length > 0) {
      return (
        <tr className="cluster-events">
          <td colSpan="5">
            <h5>Events within the last hour:</h5>
            {Array.from(events).map((event, index) => (
              <div key={event.firstTimestamp + index}>
                <i className={`event-type ${event.type.toLowerCase()}`} />
                <strong>
                  {moment(
                    event.firstTimestamp,
                    "YYYY-MM-DD HH:mm:ss ZZ Z"
                  ).format("HH:mm:ss")}
                  {event.count > 1 ? (
                    <span>
                      {" "}
                      -{" "}
                      {moment(
                        event.lastTimestamp,
                        "YYYY-MM-DD HH:mm:ss ZZ Z"
                      ).format("HH:mm:ss")}
                      {` (${event.count} times)`}
                    </span>
                  ) : undefined}
                </strong>
                <p>
                  {event.message}
                  {` (${event.reason})`}
                </p>
              </div>
            ))}
          </td>
        </tr>
      )
    } else {
      return <tr />
    }
  }
}

export default connect(
  function (state, ownProps) {
    const clusterEvents = state.clusters.events[ownProps.cluster.name]
    return { events: clusterEvents != null ? clusterEvents : [] }
  },
  (dispatch) => ({
    handleLoadClusterEvents(clusterName) {
      return dispatch(loadClusterEvents(clusterName))
    },
  })
)(Events)
