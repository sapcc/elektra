import { Link } from 'react-router-dom';

export default class AccountRow extends React.Component {
  render() {
    const { name: accountName, auth_tenant_id: projectID, replication } = this.props.account;
    const containerName = `keppel-${accountName}`;
    const swiftContainerURL = `/_/${projectID}/object-storage/containers/${containerName}/list`;

    //NOTE: This table is relatively empty at the moment. I'm considering adding stats like `N repositories, M tags, X GiB used` to the display, but that would require extending the Keppel API first.
    return (
      <tr>
        <td className='col-md-6'>
          <Link to={`/account/${accountName}`}>{accountName}</Link>
        </td>
        <td className='col-md-6'>
          { replication ? (
            <div>
              Replica of <strong>{replication.upstream}/{accountName}</strong>
            </div>
          ) : (
            <div>
              Primary account
            </div>
          )}
          <div>
            Backed by Swift container
            {' '}
            <a href={swiftContainerURL} target='_blank'>{containerName}</a>
          </div>
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
              <li><Link to={`/accounts/${accountName}/access_policies`}>Access policies</Link></li>
              {(this.props.isAdmin && !replication) && (
                <React.Fragment>
                  <li><Link to={`/accounts/${accountName}/validation_rules`}>Validation rules</Link></li>
                  <li className="divider"></li>
                  <li><Link to={`/accounts/${accountName}/sublease`}>Issue sublease token</Link></li>
                </React.Fragment>
              )}
            </ul>
          </div>
        </td>
      </tr>
    );
  }
}
