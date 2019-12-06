import { Link } from 'react-router-dom';

import { DataTable } from 'lib/components/datatable';

import AccountRow from './row';

const columns = [
  { key: 'name', label: 'Account name', sortStrategy: 'text',
    sortKey: props => props.account.name || '' },
  { key: 'storage', label: 'Backing storage', sortStrategy: 'text',
    sortKey: props => props.account.name || '' },
  { key: 'actions', label: '' },
];

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
        <DataTable columns={columns}>
          {this.props.accounts.map(account => (
            <AccountRow key={account.name} account={account} />
          ))}
        </DataTable>
      </React.Fragment>
    );
  }
};
