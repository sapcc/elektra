import { Link } from 'react-router-dom';

import { DataTable } from 'lib/components/datatable';

import { makeTabBar, makeHowto, makeHowtoOpener } from '../utils';
import ImageRow from './row';

const taggedColumns = [
  { key: 'name', label: 'Tag name / Canonical digest', sortStrategy: 'text',
    sortKey: props => props.data.name || '' },
  { key: 'media_type', label: 'Format' },
  { key: 'size_bytes', label: 'Size', sortStrategy: 'numeric',
    sortKey: props => props.data.size_bytes || 0 },
  { key: 'pushed_at', label: 'Pushed', sortStrategy: 'numeric',
    sortKey: props => props.data.pushed_at || 0 },
  { key: 'actions', label: '' },
];

const untaggedColumns = [
  { key: 'digest', label: 'Canonical digest', sortStrategy: 'text',
    sortKey: props => props.data.digest || '' },
  ...(taggedColumns.slice(1)),
];

export default class RepositoryList extends React.Component {
  state = {
    currentTab: 'tagged',
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
    const { name: repoName } = this.props.repository || {};
    if (accountName) {
      this.props.loadManifestsOnce();
    }
  }

  selectTab(tab) {
    this.setState({ ...this.state, currentTab: tab });
  }
  setHowtoVisible(howtoVisible) {
    this.setState({ ...this.state, howtoVisible });
  }

  renderTaggedImagesList(forwardProps) {
    const { isFetching, data: manifests } = this.props.manifests;
    if (isFetching) {
      return <p><span className='spinner' /> Loading tags/manifests for repository...</p>;
    }

    const tags = [];
    for (const manifest of manifests || []) {
      for (const tag of manifest.tags || []) {
        tags.push({ ...manifest, ...tag });
      }
    }
    tags.sort((a, b) => (a.name || a.digest).localeCompare(b.name || b.digest));
    return (
      <DataTable columns={taggedColumns}>
      {tags.map(tag => (
        <ImageRow key={tag.name} data={tag} {...forwardProps} />
      ))}
      </DataTable>
    );
  }

  renderUntaggedImagesList(forwardProps) {
    const { isFetching, data: manifests } = this.props.manifests;
    if (isFetching) {
      return <p><span className='spinner' /> Loading tags/manifests for repository...</p>;
    }

    const untaggedManifests = (manifests || []).filter(
      manifest => (manifest.tags || []).length == 0,
    );

    return (
      <DataTable columns={untaggedColumns}>
        {untaggedManifests.map(manifest => (
          <ImageRow key={manifest.digest} data={manifest} {...forwardProps} />
        ))}
      </DataTable>
    );
  }

  render() {
    const { account, repository } = this.props;
    if (!account) {
      return <p className='alert alert-error'>No such account</p>;
    }
    if (!repository) {
      return <p className='alert alert-error'>No such repository</p>;
    }

    const { currentTab, howtoVisible } = this.state;
    let tabs = [
      { label: 'Tags', key: 'tagged' },
      { label: 'Untagged images', key: 'untagged' },
    ];
    const hasUntagged = (this.props.manifests.data || []).some(
      manifest => (manifest.tags || []).length == 0,
    );
    if (!hasUntagged) {
      tabs = tabs.filter(tab => tab.key != 'untagged');
    }

    const showHowto = val => this.setHowtoVisible(true);
    const hideHowto = val => this.setHowtoVisible(false);

    const forwardProps = {
      canEdit:        this.props.canEdit,
      deleteManifest: this.props.deleteManifest,
    };

    return (
      <React.Fragment>
        <ol className='breadcrumb'>
          <li><Link to='/accounts'>All accounts</Link></li>
          <li><Link to={`/account/${account.name}`}>Account: {account.name}</Link></li>
          <li className='active'>Repository: {repository.name}</li>
          {!howtoVisible && makeHowtoOpener(showHowto)}
        </ol>
        {howtoVisible && makeHowto(this.props.dockerInfo, account.name, repository.name, hideHowto)}
        {/* when there is only the "Tags" tab, skip the tablist entirely */}
        {hasUntagged && makeTabBar(tabs, currentTab, key => this.selectTab(key))}
        {(!hasUntagged || currentTab == 'tagged') && this.renderTaggedImagesList(forwardProps)}
        {(hasUntagged && currentTab == 'untagged') && this.renderUntaggedImagesList(forwardProps)}
      </React.Fragment>
    );
  }

}
