import { Link } from 'react-router-dom';

import { DataTable } from 'lib/components/datatable';

import { makeTabBar, makeHowto } from '../utils';
// import ManifestRow from './row';

export default class RepositoryList extends React.Component {
  state = {
    currentTab: 'tags',
  };

  componentDidMount() {
    this.loadData();
  }
  componentDidUpdate() {
    this.loadData();
  }
  loadData() {
    const { name: accountName } = this.props.account || {};
    const { name: repoName } = this.props.repository || {};
    if (accountName) {
      this.props.loadManifestsOnce(accountName, repoName);
    }
  }

  selectTab(tab) {
    this.setState({ ...this.state, currentTab: tab });
  }

  renderTagsList() {
    return <pre>{JSON.stringify(this.props.manifests, null, 2)}</pre>;
  }
  renderUntaggedManifestsList() {
    return <p>TODO</p>;
  }

  render() {
    const { account, repository } = this.props;
    if (!account) {
      return <p className='alert alert-error'>No such account</p>;
    }
    if (!repository) {
      return <p className='alert alert-error'>No such repository</p>;
    }

    const { currentTab } = this.state;
    const tabs = [
      { label: 'Tags', key: 'tags' },
      { label: 'Untagged manifests', key: 'untagged' },
      { label: 'Instructions for Docker client', key: 'howto' },
    ];

    return (
      <React.Fragment>
        <ol className='breadcrumb'>
          <li><Link to='/accounts'>All accounts</Link></li>
          <li><Link to={`/account/${account.name}`}>Account: {account.name}</Link></li>
          <li className='active'>Repository: {repository.name}</li>
        </ol>
        {makeTabBar(tabs, currentTab, key => this.selectTab(key))}
        {currentTab == 'tags' && this.renderTagsList()}
        {currentTab == 'untagged' && this.renderUntaggedManifestsList()}
        {currentTab == 'howto' && makeHowto(this.props.dockerInfo, account.name, repository.name)}
      </React.Fragment>
    );
  }

}
