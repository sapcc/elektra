import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import { Link } from 'react-router-dom';

export default class AccountRow extends React.Component {
  render() {
    const { name: accountName, auth_tenant_id: projectID, in_maintenance: inMaintenance, replication } = this.props.account;
    const containerName = `keppel-${accountName}`;
    const swiftContainerURL = `/_/${projectID}/object-storage/containers/${containerName}/list`;

    let statusDisplay = 'Ready';
    if (inMaintenance) {
      const infoText = replication
        ? 'No new images will be replicated while the account is in maintenance. Replicated images can still be pulled.'
        : 'No new images may be pushed while the account is in maintenance. Existing images can still be pulled.';
      const tooltip = <Tooltip id={`tooltip-in-maintenance-${accountName}`}>{infoText}</Tooltip>;
      statusDisplay = (
        <OverlayTrigger overlay={tooltip} placement='top' delayShow={300} delayHide={150}>
          <div className='text-warning'>
            In maintenance
          </div>
        </OverlayTrigger>
      );
    }

    //NOTE: This table is relatively empty at the moment. I'm considering adding stats like `N repositories, M tags, X GiB used` to the display, but that would require extending the Keppel API first.
    return (
      <tr>
        <td className='col-md-4'>
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
        <td className='col-md-2'>{statusDisplay}</td>
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
              {!replication && (
                <li><Link to={`/accounts/${accountName}/validation_rules`}>Validation rules</Link></li>
              )}
              {this.props.isAdmin && (
                <React.Fragment>
                  <li className="divider"></li>
                  {!replication && (
                    <li><Link to={`/accounts/${accountName}/sublease`}>Issue sublease token</Link></li>
                  )}
                  <li><Link to={`/accounts/${accountName}/toggle_maintenance`}>{inMaintenance ? 'End maintenance' : 'Set in maintenance'}</Link></li>
                </React.Fragment>
              )}
            </ul>
          </div>
        </td>
      </tr>
    );
  }
}
