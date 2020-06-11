import { Link } from 'react-router-dom';

import { DataTable } from 'lib/components/datatable';

import AccountRow from './row';

const columns = [
  { key: 'name', label: 'Global account name', sortStrategy: 'text',
    sortKey: props => props.account.name || '' },
  { key: 'config', label: 'Configuration' },
  { key: 'status', label: 'Status' },
  { key: 'actions', label: '' },
];

const byName = (account1, account2) => {
  return account1.name.localeCompare(account2.name);
}

export default class AccountList extends React.Component {
  render() {
    return (
      <React.Fragment>
        {this.props.isAdmin && (
          <div className='toolbar'>
            <div className='main-buttons'>
              <Link to='/accounts/new' className='btn btn-primary'>New Account</Link>
            </div>
          </div>
        )}
        <DataTable columns={columns} pageSize={10}>
          {this.props.accounts.sort(byName).map(account => (
            <AccountRow key={account.name} account={account} isAdmin={this.props.isAdmin} />
          ))}
        </DataTable>
      </React.Fragment>
    );
  }
};
