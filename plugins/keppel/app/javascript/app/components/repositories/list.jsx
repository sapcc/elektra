import { Link } from 'react-router-dom';

export default class RepositoryList extends React.Component {
  state = {
    currentTab: 'repos',
  };

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

  selectTab(tab) {
    this.setState({ ...this.state, currentTab: tab });
  }

  renderRepoList() {
    const { isFetching, data: repos } = this.props.repos;
    if (isFetching) {
      return <p><span className='spinner' /> Loading repositories for account...</p>;
    }
    return <pre>{JSON.stringify(repos, null, 2)}</pre>;
  }

  renderHowto() {
    const { account } = this.props;
    const { registryDomain, userName } = this.props.dockerInfo;

    return (
      <ol className='howto'>
        <li>
          Log in with your OpenStack credentials:
          <pre><code>
            {`$ docker login ${registryDomain}\nUsername: `}
            <strong>{userName}</strong>
            {`\nPassword: `}
            <strong>{`<your password>`}</strong>
          </code></pre>
        </li>
        <li>
          To push an image, use this command:
          <pre><code>{`$ docker push ${registryDomain}/${account.name}/<repo>:<tag>`}</code></pre>
        </li>
        <li>
          To pull an image, use this command:
          <pre><code>{`$ docker pull ${registryDomain}/${account.name}/<repo>:<tag>`}</code></pre>
          When the repository permits anonymous pulling, logging in is not required. Check <Link to={`/accounts/${account.name}/policies`}>the account's access policies</Link> for details.
        </li>
      </ol>
    );
  }

  render() {
    const { account } = this.props;
    if (!account) {
      return <p className='alert alert-error'>No such account</p>;
    }

    const { currentTab } = this.state;
    const tabs = [
      { label: 'Repositories', key: 'repos' },
      { label: 'Instructions for Docker client', key: 'howto' },
    ];

    return (
      <React.Fragment>
        <ol className='breadcrumb'>
          <li><Link to='/accounts'>All accounts</Link></li>
          <li className='active'>{account.name}</li>
        </ol>
        <nav className='nav-with-buttons'>
          <ul className='nav nav-tabs'>
            { tabs.map(tab => (
              <li key={tab.key} role='presentation' className={currentTab == tab.key ? 'active' : ''}>
                <a onClick={() => this.selectTab(tab.key)}>{tab.label}</a>
              </li>
            ))}
          </ul>
        </nav>
        {currentTab == 'repos' && this.renderRepoList()}
        {currentTab == 'howto' && this.renderHowto()}
      </React.Fragment>
    );
  }
}
