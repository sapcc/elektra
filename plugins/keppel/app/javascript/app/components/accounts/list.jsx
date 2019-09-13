export default class AccountList extends React.Component {
  componentWillReceiveProps(nextProps) {
    this.loadDependencies(nextProps);
  }
  componentDidMount() {
    this.loadDependencies(this.props);
  }
  loadDependencies(props) {
    props.loadAccountsOnce();
  }

  render() {
    if (this.props.isFetching) {
      return <p><span className='spinner' /> Loading...</p>;
    }
    return <pre>{JSON.stringify(this.props.accounts, null, 2)}</pre>;
  }
};
