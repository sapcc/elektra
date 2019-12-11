import { Link } from 'react-router-dom';

import { DataTable } from 'lib/components/datatable';

import { makeTabBar, makeHowto, makeHowtoOpener } from '../utils';
import RepositoryRow from './row';

const columns = [
  { key: 'name', label: 'Repository name', sortStrategy: 'text',
    sortKey: props => props.repo.name || '' },
  { key: 'image_counts', label: 'Contains', sortStrategy: 'numeric',
    sortKey: props => (props.repo.tag_count || 0) + 0.00001 * (props.repo.manifest_count || 0) },
  { key: 'size_bytes', label: 'Size (before deduplication)', sortStrategy: 'numeric',
    sortKey: props => props.repo.size_bytes || 0 },
  { key: 'pushed_at', label: 'Last pushed', sortStrategy: 'numeric',
    sortKey: props => props.repo.pushed_at || 0 },
];

export default class RepositoryList extends React.Component {
  state = {
    currentTab: 'repos',
    howtoVisible: false,
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
  setHowtoVisible(howtoVisible) {
    this.setState({ ...this.state, howtoVisible });
  }

  renderRepoList() {
    const { isFetching, data: repos } = this.props.repos;
    if (isFetching) {
      return <p><span className='spinner' /> Loading repositories for account...</p>;
    }
    return (
      <DataTable columns={columns}>
        {(repos || []).map(repo => (
          <RepositoryRow key={repo.name} repo={repo} account={this.props.account} />
        ))}
      </DataTable>
    );
  }

  render() {
    const { account } = this.props;
    if (!account) {
      return <p className='alert alert-error'>No such account</p>;
    }

    const { currentTab, howtoVisible } = this.state;
    const tabs = [
      { label: 'Repositories', key: 'repos' },
    ];
    const showHowto = val => this.setHowtoVisible(true);
    const hideHowto = val => this.setHowtoVisible(false);

    return (
      <React.Fragment>
        <ol className='breadcrumb'>
          <li><Link to='/accounts'>All accounts</Link></li>
          <li className='active'>Account: {account.name}</li>
          {!howtoVisible && makeHowtoOpener(showHowto)}
        </ol>
        {howtoVisible && makeHowto(this.props.dockerInfo, account.name, '<repo>', hideHowto)}
        {makeTabBar(tabs, currentTab, key => this.selectTab(key))}
        {currentTab == 'repos' && this.renderRepoList()}
      </React.Fragment>
    );
  }
}
