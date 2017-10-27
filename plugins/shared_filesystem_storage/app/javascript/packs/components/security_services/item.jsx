import { Link } from 'react-router-dom';

export default ({ securityService, handleDelete }) =>
  <tr className={ (securityService.isFetching || securityService.isDeleting) ? 'updating' : ''}>
    <td>
      <Link to={`/security-services/${securityService.id}`}>{securityService.name}</Link>
      <br/>
      <span className='info-text'>{securityService.id}</span>
    </td>
    <td>{securityService.type}</td>
    <td>{securityService.status}</td>
    <td className="snug">
      { true && //delete or update permission
        <div className='btn-group'>
          <button className='btn btn-default btn-sm dropdown-toggle' type='button' data-toggle='dropdown' aria-expanded={true}>
            <span className='fa fa-cog'></span>
          </button>

          <ul className='dropdown-menu dropdown-menu-right' role="menu">
            { true && //securityService.permissions.delete
              <li>
                <a onClick={(e) => {e.preventDefault(); handleDelete(securityService.id)}}>Delete</a>
              </li>
            }
            { true && //securityService.permissions.update
              <li><Link to={`/security-services/${securityService.id}/edit`}>Edit</Link></li>
            }
          </ul>
        </div>
      }
    </td>
  </tr>
