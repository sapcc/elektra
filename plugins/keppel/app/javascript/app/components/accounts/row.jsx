import { Link } from 'react-router-dom';

export default class AccountRow extends React.Component {
  render() {
    const { name: accountName, auth_tenant_id: projectID } = this.props.account;
    const containerName = `keppel-${accountName}`;
    const swiftContainerURL = `/_/${projectID}/object-storage/containers/${containerName}/list`;

    //NOTE: This table is relatively empty at the moment. I'm considering adding stats like `N repositories, M tags, X GiB used` to the display, but that would require extending the Keppel API first.
    //TODO: link from first column to some DetailsModal that lists RBAC policies and explains how to use `docker pull/push` with this account
    return (
      <tr>
        <td className='col-md-6'>
          <Link to={`/account/${accountName}`}>{accountName}</Link>
        </td>
        <td className='col-md-6'>
          Swift container
          {' '}
          <a href={swiftContainerURL} target='_blank'>{containerName}</a>
        </td>
        <td className='snug'>
          <div className='btn-group'>
            <button
              className='btn btn-default btn-sm dropdown-toggle'
              type='button'
              data-toggle='dropdown'
              aria-expanded={true}>
              <span className="fa fa-cog"></span>
            </button>
            <ul className="dropdown-menu dropdown-menu-right" role="menu">
              <li><Link to={`/accounts/${accountName}/policies`}>Access policies</Link></li>
            </ul>
          </div>
        </td>
      </tr>
    );
  }
}
