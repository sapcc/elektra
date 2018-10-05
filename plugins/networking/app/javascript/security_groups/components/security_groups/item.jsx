import { Link } from 'react-router-dom';

export default ({
  securityGroup,
  handleDelete
}) => {

  const canDelete = policy.isAllowed("networking:security_group_delete")
  const canUpdate = false; //policy.isAllowed("networking:security_group_update")

  return (
    <tr className={securityGroup.deleting ? 'updating' : ''}>
      <td>
        { policy.isAllowed("networking:security_group_get") ?
          <Link to={`/security-groups/${securityGroup.id}/rules`}>
            {securityGroup.name || securityGroup.id}
          </Link>
          :
          securityGroup.name || securityGroup.id
        }
        {securityGroup.name &&
          <React.Fragment>
            <br/>
            <span className='info-text'>{securityGroup.id}</span>
          </React.Fragment>
        }
      </td>
      <td>{securityGroup.description}</td>
      <td>
        {(canDelete || canUpdate) && securityGroup.name!='default' &&
          <div className='btn-group'>
            <button
              className="btn btn-default btn-sm dropdown-toggle"
              type="button"
              disabled={securityGroup.deleting}
              data-toggle="dropdown"
              aria-expanded="true">
              <i className='fa fa-cog'></i>
            </button>
            <ul className='dropdown-menu dropdown-menu-right' role="menu">
              { canUpdate &&
                <li>
                  <Link to={`/${securityGroup.id}/edit`}>
                    Edit
                  </Link>
                </li>
              }
              { canDelete &&
                <li>
                  <a href='#' onClick={ (e) => { e.preventDefault(); handleDelete(securityGroup.id) } }>
                    Delete
                  </a>
                </li>
              }
            </ul>
          </div>
        }
      </td>
    </tr>
  )
}
