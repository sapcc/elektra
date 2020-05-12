import { Link } from 'react-router-dom';

import { DataTable } from 'lib/components/datatable';

import { makeHowto, makeHowtoOpener } from '../utils';
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
  { key: 'actions', label: '' },
];

export default class RepositoryList extends React.Component {
  state = {
    //either `true` or `false` when set by user, or `null` to apply default visibility rule (see below)
    howtoVisible: null,
  };

  componentDidMount() {
    this.props.loadRepositoriesOnce();
  }
  componentDidUpdate() {
    this.props.loadRepositoriesOnce();
  }

  setHowtoVisible(howtoVisible) {
    this.setState({ ...this.state, howtoVisible });
  }

  render() {
    const { account } = this.props;
    if (!account) {
      return <p className='alert alert-error'>No such account</p>;
    }
    const { isFetching, data: repos } = this.props.repos;

    let howtoVisible = this.state.howtoVisible;
    if (howtoVisible === null) {
      //by default, unfold the howto if the account is empty (to make sure that
      //new users see it, without cluttering the view for experienced users)
      howtoVisible = repos instanceof Array && repos.length == 0;
    }

    const showHowto = val => this.setHowtoVisible(true);
    const hideHowto = val => this.setHowtoVisible(false);

    const forwardProps = {
      accountName: account.name,
      canEdit:     this.props.canEdit,
    };

    return (
      <React.Fragment>
        <ol className='breadcrumb'>
          <li><Link to='/accounts'>All accounts</Link></li>
          <li className='active'>Account: {account.name}</li>
          {!howtoVisible && makeHowtoOpener(showHowto)}
        </ol>
        {howtoVisible && makeHowto(this.props.dockerInfo, account.name, '<repo>', hideHowto)}
        {isFetching ? (
          <p><span className='spinner' /> Loading repositories for account...</p>
        ) : (
          <DataTable columns={columns} pageSize={10}>
            {(repos || []).map(repo => (
              <RepositoryRow key={repo.name} repo={repo} {...forwardProps} />
            ))}
          </DataTable>
        )}
      </React.Fragment>
    );
  }
}
