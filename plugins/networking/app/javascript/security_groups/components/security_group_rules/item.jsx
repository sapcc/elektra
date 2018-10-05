import { Link } from 'react-router-dom';
import {
  SECURITY_GROUP_RULE_DESCRIPTIONS,
  SECURITY_GROUP_RULE_PREDEFINED_TYPES,
  SECURITY_GROUP_RULE_PROTOCOLS
} from '../../constants'

export default ({rule,handleDelete,securityGroups}) => {
  const displayPort = () => {
    let port;

    if(!rule.port_range_min && !rule.port_range_max) return 'Any'
    else if(!rule.port_range_min && rule.port_range_max) port = rule.port_range_max
    else if(rule.port_range_min && !rule.port_range_max) port = rule.port_range_min
    else if(rule.port_range_min == rule.port_range_max) port = rule.port_range_min
    else port = `${rule.port_range_min}-${rule.port_range_max}`

    rule = SECURITY_GROUP_RULE_PREDEFINED_TYPES.find(r => r.portRange==port)
    if(rule) port = port + ` (${rule.label})`
    return port
  }

  const remoteSecurityGroup = () => {
    let group = securityGroups.find(g => g.id == rule.remote_group_id)
    if(!group) return rule.remote_group_id
    return group.name
  }

  const canDelete = policy.isAllowed("networking:rule_delete")

  return (
    <tr className={rule.deleting ? 'updating' : ''}>
      <td>{rule.direction}</td>
      <td>{rule.ethertype}</td>
      <td>{rule.protocol || 'Any'}</td>
      <td>{displayPort()}</td>
      <td>
        {rule.remote_ip_prefix ?
          `IP: ${rule.remote_ip_prefix}`
          : rule.remote_group_id ? `Group: ${remoteSecurityGroup()}`
          : '-'
        }
      </td>
      <td>{rule.description}</td>
      <td>
        {canDelete &&
          <a
            className='btn btn-default btn-sm'
            href='#'
            onClick={ (e) => { e.preventDefault(); handleDelete(rule.id) } }>
            <i className="fa fa-trash fa-fw"></i> Remove
          </a>
        }
      </td>
    </tr>
  )
}
