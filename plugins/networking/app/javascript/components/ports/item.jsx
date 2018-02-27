import { Link } from 'react-router-dom';

export default ({port,network,isFetchingNetworks,subnets,isFetchingSubnets,handleDelete}) =>
  <tr className={ port.isDeleting ? 'updating' : ''}>
    <td>
      { policy.isAllowed("networking:port_get", {port: port}) ?
        <Link to={`/ports/${port.id}/show`}>{port.description || port.id}</Link>
        :
        port.description || port.id
      }
    </td>
    <td>
      { (network && network.name) || port.network_id }
      { isFetchingNetworks && <span className='spinner'></span> }
    </td>
    <td>
      { (port.fixed_ips || []).map((ip) => (subnets[ip.subnet_id] || {}).name || ip.subnet_id)}
      { isFetchingSubnets && <span className='spinner'></span> }
    </td>
    <td>
      { (port.fixed_ips || []).map((ip) => ip.ip_address)}
    </td>
    <td>{ port.status }</td>

    <td className="snug">
      { policy.isAllowed("networking:port_delete", {port: port}) &&

        <div className='btn-group'>
          <button className="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">
            <i className='fa fa-cog'></i>
          </button>
          <ul className='dropdown-menu dropdown-menu-right' role="menu">
            { policy.isAllowed("networking:port_delete", {port: port}) &&
              <li><a href='#' onClick={ (e) => { e.preventDefault(); handleDelete(port.id) } }>Delete</a></li>
            }
          </ul>
        </div>
      }
    </td>
  </tr>
