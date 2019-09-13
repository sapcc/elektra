import { DataTable } from 'lib/components/datatable';
import AccountRow from './row';

const columns = [
  { key: 'name', label: 'Account name', sortStrategy: 'text',
    sortKey: props => props.account.name || '' },
  { key: 'storage', label: 'Backing storage', sortStrategy: 'text',
    sortKey: props => props.account.name || '' },
  { key: 'rbac_policies', label: 'Additional access rules' },
  { key: 'actions', label: 'Actions' },
];

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
    return (
      <DataTable columns={columns}>
        {this.props.accounts.map(account => (
          <AccountRow account={account} />
        ))}
      </DataTable>
    );
  }
};
