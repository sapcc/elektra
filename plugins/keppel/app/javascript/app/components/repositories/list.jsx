import { Link } from 'react-router-dom';

export default class RepositoryList extends React.Component {
  componentDidMount() {
    this.loadData();
  }
  componentDidUpdate() {
    this.loadData();
  }
  loadData() {
    const { name: accountName } = this.props.account || {};
    if (accountName) {
      this.props.loadRepositoriesOnce(accountName);
    }
  }

  renderRepoList() {
    const { isFetching, data: repos } = this.props.repos;
    if (isFetching) {
      return <p><span className='spinner' /> Loading repositories for account...</p>;
    }
    return <pre>{JSON.stringify(repos, null, 2)}</pre>;
  }

  render() {
    const { account } = this.props;
    if (!account) {
      return <p className='alert alert-error'>No such account</p>;
    }

    return (
      <React.Fragment>
        <ol className='breadcrumb'>
          <li><Link to='/accounts'>All accounts</Link></li>
          <li className='active'>{account.name}</li>
        </ol>
        {this.renderRepoList()}
      </React.Fragment>
    );
  }
}
