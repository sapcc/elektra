import { Link } from 'react-router-dom';
import { truncate } from 'lib/tools/helpers'
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

export const AttachedIcon = ({port}) => {
  if(!port.device_id) return null;

  const tooltip = <Tooltip id='attachedIconTooltip'>Port is attached</Tooltip>;

  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      delayShow={300}
      delayHide={150}>
      <i className='fa fa-fw fa-paperclip'/>
    </OverlayTrigger>
  )
}

export default ({
  port,
  instancesPath,
  network,
  isFetchingNetworks,
  subnets,
  isFetchingSubnets,
  handleDelete}) => {

  const FIXED = 'fixed_ip_allocation'
  const canDelete = policy.isAllowed("networking:port_delete", {port: port}) && (!port.device_id || port.name==FIXED)

  return (
    <tr className={ port.isDeleting ? 'updating' : ''}>
      <td><AttachedIcon port={port}/></td>
      <td>
        { policy.isAllowed("networking:port_get", {port: port}) ?
          <Link to={`/ports/${port.id}/show`}>{port.description || truncate(port.id,20)}</Link>
          :
          port.description || truncate(port.id,20)
        }
      </td>
      <td>
        { (network && network.name) || port.network_id }
        { isFetchingNetworks && <span className='spinner'></span> }

      </td>
      <td>
        { (port.fixed_ips || []).map((ip,index) =>
          <div key={index}>
            {ip.ip_address}
            <br/>
            {isFetchingSubnets ?
              <span className='spinner'></span>
              :
              <span className='info-text'>
                {(subnets[ip.subnet_id] || {}).name || truncate(ip.subnet_id,20)}
              </span>
            }
          </div>
        )}
      </td>
      <td>
        { port.device_owner }
        { port.device_id &&
          <React.Fragment>
            <br/><span className='info-text'>
              { port.device_owner && port.device_owner.indexOf('compute:') >= 0 ?
                <a href={`${instancesPath}/${port.device_id}`} data-modal='true'>{truncate(port.device_id, 20)}</a>
                :
                truncate(port.device_id, 20)
              }
            </span>
          </React.Fragment>
        }
      </td>
      <td>{ port.status }</td>

      <td className="snug">
        <div className='btn-group'>
          <button className="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">
            <i className='fa fa-cog'></i>
          </button>
          <ul className='dropdown-menu dropdown-menu-right' role="menu">
            <li><Link to={`/ports/${port.id}/show`}>Show</Link></li>
            <li><Link to={`/ports/${port.id}/edit`}>Edit</Link></li>
            { canDelete &&
              <li><a href='#' onClick={ (e) => { e.preventDefault(); handleDelete(port.id) } }>Delete</a></li>
            }
          </ul>
        </div>
      </td>
    </tr>
  )
}
