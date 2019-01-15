export default class ProjectSyncAction extends React.Component {
  componentDidMount() {
    this.configurePolling(this.props.syncStatus);
  }

  componentDidUpdate() {
    this.configurePolling(this.props.syncStatus);
  }

  componentWillUnmount() {
    this.configurePolling('shutdown');
  }

  configurePolling = (syncStatus) => {
    // start polling when entering 'started' state, stop polling when leaving it
    if (syncStatus == 'started') {
      if (!this.polling) {
        const pollAction = () => this.props.pollRunningSyncProject({
          domainID: this.props.domainID,
          projectID: this.props.projectID,
        });
        this.polling = setInterval(pollAction, 3000);
      }
    } else {
      if (this.polling) {
        clearInterval(this.polling);
        this.polling = null;
      }
    }
  }

  handleStartSync = (e) => {
    e.preventDefault();
    this.props.syncProject({
      domainID: this.props.domainID,
      projectID: this.props.projectID,
    });
  }

  render() {
    let msg;
    switch (this.props.syncStatus) {
      case 'requested':
        msg = <React.Fragment><span className='spinner'/>Syncing...</React.Fragment>;
        break;
      case 'started':
        msg = <React.Fragment><span className='spinner'/>Sync in progress...</React.Fragment>;
        break;
      case 'reloading':
        msg = <React.Fragment><span className='spinner'/>Reloading project...</React.Fragment>;
        break;
      default:
        msg = <a href='#' onClick={this.handleStartSync}>Sync now</a>;
        break;
    }
    return <span>&ndash; {msg}</span>;
  }
}
