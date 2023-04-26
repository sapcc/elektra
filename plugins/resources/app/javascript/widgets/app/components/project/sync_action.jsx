import React from "react"
export default class ProjectSyncAction extends React.Component {
  componentDidMount() {
    this.configurePolling(this.props.syncStatus)
  }

  componentDidUpdate() {
    this.configurePolling(this.props.syncStatus)
  }

  componentWillUnmount() {
    this.configurePolling("shutdown")
  }

  configurePolling = (syncStatus) => {
    // start polling when entering 'started' state, stop polling when leaving it
    if (syncStatus == "started") {
      if (!this.polling) {
        const pollAction = () =>
          this.props.pollRunningSyncProject(this.props.scopeData)
        this.polling = setInterval(pollAction, 3000)
      }
    } else {
      if (this.polling) {
        clearInterval(this.polling)
        this.polling = null
      }
    }
  }

  handleStartSync = (e) => {
    e.preventDefault()
    this.props.syncProject(this.props.scopeData)
  }

  render() {
    let msg
    switch (this.props.syncStatus) {
      case "requested":
        msg = (
          <>
            <span className="spinner" />
            Syncing...
          </>
        )
        break
      case "started":
        msg = (
          <>
            <span className="spinner" />
            Sync in progress...
          </>
        )
        break
      case "reloading":
        msg = (
          <>
            <span className="spinner" />
            Reloading project...
          </>
        )
        break
      default:
        msg = (
          <a href="#" onClick={this.handleStartSync}>
            Sync usage info now
          </a>
        )
        break
    }
    return <span>&ndash; {msg}</span>
  }
}
