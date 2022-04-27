# import
{ tr, td, h5, p, strong, div, i, span } = React.DOM
{ connect } = ReactRedux
{ loadClusterEvents } = kubernetes



Events = React.createClass

  componentDidMount: ->
    @props.handleLoadClusterEvents(@props.cluster.name)
    @startPollingClusterEvents()


  startPollingClusterEvents: () ->
    clearInterval(@pollingEvents)
    @pollingEvents = setInterval((() => @props.handleLoadClusterEvents(@props.cluster.name)), 60000)

  render: ->
    {cluster, events, handleLoadClusterEvents} = @props

    if events.length > 0
      tr className: 'cluster-events',
        td colSpan: '5',
          h5 null, "Events within the last hour:"
          for event, index in events
            div key: event.firstTimestamp+index,
              i className: "event-type #{event.type.toLowerCase()}"
              strong null,
                moment(event.firstTimestamp, 'YYYY-MM-DD HH:mm:ss ZZ Z').format("HH:mm:ss")
                if (event.count > 1)
                  span null,
                    " - "
                    moment(event.lastTimestamp, 'YYYY-MM-DD HH:mm:ss ZZ Z').format("HH:mm:ss")
                    " (#{event.count} times)"

              p null,
                event.message
                " (#{event.reason})"
    else
      tr null





Events = connect(
  (state, ownProps) ->
    clusterEvents = state.clusters.events[ownProps.cluster.name]
    events: (if clusterEvents? then clusterEvents else [] )


  (dispatch) ->
    handleLoadClusterEvents:  (clusterName) -> dispatch(loadClusterEvents(clusterName))


)(Events)


# export
kubernetes.ClusterEvents = Events
