import { Link } from 'react-router-dom';
import { Popover, Tooltip, OverlayTrigger } from 'react-bootstrap';
import { policy } from 'policy';

const emptyNetwork = (
  <Popover id="popover-empty-share-network" title="Empty Network">
    This network does not contain any shares or security services. Please note that once a share is created on this network, you will no longer be able to add a security service. Please add the security service first if necessary.
  </Popover>
);

const tooltipExternalNetwork = (
  <Tooltip id="tooltip-external-network">External Network</Tooltip>
);

const tooltipSharedNetwork = (
  <Tooltip id="tooltip-shared-network">Shared Network</Tooltip>
);

export default ({
  shareNetwork,
  handleDelete,
  handleShareNetworkSecurityServices,
  network,
  subnet
}) => {
  let className = ''
  if(shareNetwork.isDeleting) {
    className = 'updating'
  } else if (shareNetwork.isNew) {
    className = 'bg-info'
  }

  return (
    <tr className={className}>
      <td>
        { shareNetwork.isNew &&
          <OverlayTrigger trigger="click" placement="top" rootClose overlay={emptyNetwork}>
            <a href='javascript:void(0)'><i className='fa fa-fw fa-info-circle'/></a>
          </OverlayTrigger>
        }
      </td>
      <td>
        { policy.isAllowed("shared_filesystem_storage:share_network_get") ? (
          <Link to={`/share-networks/${shareNetwork.id}/show`}>{shareNetwork.name}</Link>
        ) : (
          shareNetwork.name
        )}
      </td>
      <td>
        { network ? (
          network=='loading' ? (
            <span className='spinner'/>
          ) : (
            <div>
              {network.name}
              { network['router:external'] &&
                <OverlayTrigger placement="right" overlay={tooltipExternalNetwork}>
                  <i className="fa fa-fw fa-globe"/>
                </OverlayTrigger>
              }
              { network.shared &&
                <OverlayTrigger placement="right" overlay={tooltipSharedNetwork}>
                  <i className="fa fa-fw fa-share-alt"/>
                </OverlayTrigger>
              }
            </div>
          )
        ) : (
          'Not found'
        )}
      </td>
      <td>
        { subnet ? (
          subnet=='loading' ? (
            <span className='spinner'/>
          ) : (
            <div>{subnet.name} {subnet.cidr}</div>
          )
        ) : ('Not found')}
      </td>
      <td className="snug">
        { (policy.isAllowed("shared_filesystem_storage:share_network_delete") ||
           policy.isAllowed("shared_filesystem_storage:share_network_update")) &&
          <div className='btn-group'>
            <button className='btn btn-default btn-sm dropdown-toggle'
              type='button'
              data-toggle='dropdown'
              aria-expanded={true}>
              <span className='fa fa-cog'/>
            </button>

            <ul className='dropdown-menu dropdown-menu-right' role="menu">
              { policy.isAllowed('shared_filesystem_storage:share_network_delete') &&
                <li>
                  <a href='#' onClick={ e => {e.preventDefault(); handleDelete(shareNetwork.id)} }>Delete</a>
                </li>
              }
              { policy.isAllowed('shared_filesystem_storage:share_network_update') &&
                <li>
                  <Link to={`/share-networks/${shareNetwork.id}/edit`}>Edit</Link>
                </li>
              }
              { policy.isAllowed('shared_filesystem_storage:share_network_update') &&
                <li>
                  <Link to={`/share-networks/${shareNetwork.id}/security-services`}>Security Services</Link>
                </li>
              }
              <li>
                <Link to={`/share-networks/${shareNetwork.id}/error-log`}>Error Log</Link>
              </li>
            </ul>
          </div>
        }
      </td>
    </tr>
  )
}
