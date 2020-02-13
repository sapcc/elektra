export default class Loader extends React.Component {
  componentDidMount() {
    this.props.loadAccountsOnce();
    this.props.loadPeersOnce();
  }
  componentDidUpdate() {
    this.props.loadAccountsOnce();
    this.props.loadPeersOnce();
  }

  render() {
    const { isFetching, isLoaded, children } = this.props;
    return (
        isFetching ? <p><span className='spinner' /> Loading accounts...</p>
      : isLoaded   ? <React.Fragment>{children}</React.Fragment>
      :              <p className='alert alert-error'>Could not load accounts.</p>
    );
  }
}
