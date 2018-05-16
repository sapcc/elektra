import { Link } from 'react-router-dom'
import { SearchHighlight } from 'lib/components/search_highlight'
import projectUrl from '../../shared/project_link'

const ObjectLink = ({id, name, term}) =>
  <React.Fragment>
    <Link to={`/project-user-role-assignments/${id}/show?tab=roles`}>
      {name ?
        <SearchHighlight term={term} text={name}/>
        :
        <SearchHighlight term={term} text={id}/>
      }
    </Link>
    {name &&
      <React.Fragment>
        <br/>
        <span className='info-text'>
          <SearchHighlight term={term} text={id}/>
        </span>
      </React.Fragment>
    }
  </React.Fragment>

export default ({item, domain, project}) => {
  const scope = item.payload.scope || {}
  const projectLink = projectUrl(item)

  return (
    <tr>
      <td>
        {/* Domain */}
        <ObjectLink
          id={(scope.domain_id || item.domain_id)}
          name={scope.domain_name}
          term={domain}/>
      </td>
      <td>
        {/* Project */}
        <ObjectLink
          id={item.id}
          name={item.name}
          term={project}/>
      </td>
      <td>
        <div className='btn-group'>
          <button className="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">
            <i className='fa fa-cog'></i>
          </button>
          <ul className='dropdown-menu dropdown-menu-right' role="menu">
            {projectLink &&
              <li>
                <a
                  href={projectLink}
                  target='_blank'>
                  <i className='fa fa-fw fa-external-link'/> Switch to Project
                </a>
              </li>
            }
            <li>
              <Link to={`/project-user-role-assignments/${item.id}/show`}>
                Role Assignments
              </Link>
            </li>
          </ul>
        </div>
      </td>
    </tr>
  )
}
