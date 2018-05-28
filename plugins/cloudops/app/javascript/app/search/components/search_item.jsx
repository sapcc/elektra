import { Link } from 'react-router-dom'
import { Highlighter } from 'react-bootstrap-typeahead'
import projectUrl from '../../shared/project_link'

const ObjectLink = ({id, name, term}) =>
  <React.Fragment>
    <Link to={`/universal-search/${id}/show`} state={{test: 'ok'}}>
      {name ?
        <Highlighter search={term || ''}>{name || ''}</Highlighter>
        :
        <Highlighter search={term || ''}>{id || ''}</Highlighter>
      }
    </Link>
    {name &&
      <React.Fragment>
        <br/>
        <span className='info-text'>
          <Highlighter search={term || ''}>{id || ''}</Highlighter>
        </span>
      </React.Fragment>
    }
  </React.Fragment>

export default ({item, term}) => {
  const scope = item.payload.scope || {}
  const projectLink = projectUrl(item)

  return(
    <tr>
      <td>{item.cached_object_type}</td>
      <td className="big-data-cell">
        {/* Object */}
        <ObjectLink
          id={item.id}
          name={item.name}
          term={term}/>
      </td>
      <td className="big-data-cell">
        {/* Domain */}
        <ObjectLink
          id={(scope.domain_id || item.domain_id)}
          name={scope.domain_name}
          term={term}/>
      </td>
      <td className="big-data-cell">
        {/* Project */}
        <ObjectLink
          id={scope.project_id}
          name={scope.project_name}
          term={term}/>
      </td>
      <td>
        {projectLink &&
          <div className='btn-group'>
            <button className="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">
              <i className='fa fa-cog'></i>
            </button>
            <ul className='dropdown-menu dropdown-menu-right' role="menu">
              <li>
                <a
                  href={projectLink}
                  target='_blank'>
                  <i className='fa fa-fw fa-external-link'/> Switch to Project
                </a>
              </li>
            </ul>
          </div>
        }
      </td>
    </tr>
  )
}
