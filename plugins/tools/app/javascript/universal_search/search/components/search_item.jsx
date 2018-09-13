import { Link } from 'react-router-dom'
import { Highlighter } from 'react-bootstrap-typeahead'
import { projectUrl, objectUrl } from '../../shared/object_link_helper'
import moment from 'moment'


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
        <span className='info-text u-text-monospace u-text-small'>
          <Highlighter search={term || ''}>{id || ''}</Highlighter>
        </span>
      </React.Fragment>
    }
  </React.Fragment>

const ObjectInfo = ({id, name, term}) =>
  name ?
    <React.Fragment>
      <Highlighter search={term || ''}>{name}</Highlighter>
      <br/>
      <span className='info-text u-text-monospace u-text-small'>
        <Highlighter search={term || ''}>{id || ''}</Highlighter>
      </span>
    </React.Fragment>
    :
    <Highlighter search={term || ''}>{id || ''}</Highlighter>


export default ({item, term}) => {
  const scope = item.payload.scope || {}
  const projectLink = projectUrl(item)
  const objectLink = objectUrl(item)

  return(
    <tr>
      <td className="big-data-cell">{item.cached_object_type}</td>
      <td className="big-data-cell">
        {/* Object */}
        <ObjectLink
          id={item.id}
          name={item.name}
          term={term}/>
      </td>
      <td className="big-data-cell">
        {item.search_label && item.search_label.trim().length>0 &&
          <React.Fragment>
            <span className="info-text">
              <Highlighter search={term || ''}>{item.search_label}</Highlighter>
            </span>
            <br />
          </React.Fragment>
        }
        <span className="info-text">Last Updated: {moment(item.updated_at).fromNow()}</span>
      </td>
      <td className="big-data-cell">
        {/* Domain */}
        {policy.isAllowed("tools:show_scope_object") ?
          <ObjectLink
            id={(scope.domain_id || item.domain_id)}
            name={scope.domain_name}
            term={term}/>
          :
          <ObjectInfo
            id={(scope.domain_id || item.domain_id)}
            name={scope.domain_name}
            term={term}/>
        }

      </td>
      <td className="big-data-cell">
        {/* Project */}
        {policy.isAllowed("tools:show_scope_object") ?
          <ObjectLink
            id={scope.project_id}
            name={scope.project_name}
            term={term}/>
          :
          <ObjectInfo
            id={scope.project_id}
            name={scope.project_name}
            term={term}/>
        }
      </td>
      <td>
        {(projectLink || objectLink) &&
          <div className='btn-group'>
            <button className="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">
              <i className='fa fa-cog'></i>
            </button>
            <ul className='dropdown-menu dropdown-menu-right' role="menu">
              {objectLink &&
                <li>
                  <a
                    href={objectLink}
                    target='_blank'>
                    <i className='fa fa-fw fa-external-link'/> Show in Elektra
                  </a>
                </li>
              }
              {projectLink &&
                <li>
                  <a
                    href={projectLink}
                    target='_blank'>
                    <i className='fa fa-fw fa-external-link'/> Switch to Project
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
