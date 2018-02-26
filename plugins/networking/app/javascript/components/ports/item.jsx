import { Link } from 'react-router-dom';

export default ({port}) =>
  <tr className={ port.isDeleting ? 'updating' : ''}>
    <td>
      <Link to={`/ports/${port.id}/show`}>{port.id}</Link>
    </td>
    <td>{port.network_id}</td>
    <td>{port.fixed_ips[0].subnet_id}</td>
    <td>{port.fixed_ips[0].ip_address}</td>
    <td>{ port.status }</td>
    <td>Actions</td>
  </tr>
