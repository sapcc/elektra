import EventList from "../containers/events/list"
import React from "react"
export default class App extends React.Component {
  constructor(props) {
    super(props)
  }

  componentDidMount() {
    this.props.loadEvents()
  }

  render() {
    return (
      <EventList
        events={this.props.events}
        isFetching={this.props.isFetching}
        loadEvents={this.props.loadEvents}
      />
    )
  }
}
