# import
import { connect } from "react-redux"
import { loadClusterEvents } from "../../actions"
import moment from "moment"

class Events extends React.Component 

  componentDidMount: ->
    @props.handleLoadClusterEvents(@props.cluster.name)
    @startPollingClusterEvents()


  startPollingClusterEvents: () ->
    clearInterval(@pollingEvents)
    @pollingEvents = setInterval((() => @props.handleLoadClusterEvents(@props.cluster.name)), 60000)

  render: ->
    {cluster, events, handleLoadClusterEvents} = @props

    if events.length > 0
      React.createElement 'tr', className: 'cluster-events',
        React.createElement 'td', colSpan: '5',
          React.createElement 'h5', null, "Events within the last hour:"
          for event, index in events
            React.createElement 'div', key: event.firstTimestamp+index,
              React.createElement 'i', className: "event-type #{event.type.toLowerCase()}"
              React.createElement 'strong', null,
                moment(event.firstTimestamp, 'YYYY-MM-DD HH:mm:ss ZZ Z').format("HH:mm:ss")
                if (event.count > 1)
                  React.createElement 'span', null,
                    " - "
                    moment(event.lastTimestamp, 'YYYY-MM-DD HH:mm:ss ZZ Z').format("HH:mm:ss")
                    " (#{event.count} times)"

              React.createElement 'p', null,
                event.message
                " (#{event.reason})"
    else
      React.createElement 'tr', null





Events = connect(
  (state, ownProps) ->
    clusterEvents = state.clusters.events[ownProps.cluster.name]
    events: (if clusterEvents? then clusterEvents else [] )


  (dispatch) ->
    handleLoadClusterEvents:  (clusterName) -> dispatch(loadClusterEvents(clusterName))


)(Events)


# export
export default Events
