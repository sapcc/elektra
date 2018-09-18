import {Link} from 'react-router-dom';
import { scope } from 'ajax_helper';
import { Highlighter } from 'react-bootstrap-typeahead';

const MyHighlighter = ({search,children}) => {
  if(!search || !children) return children
  return <Highlighter search={search}>{children+''}</Highlighter>
}

export default ({volume, searchTerm = ''}) =>
  <tr className={`state-${volume.status}`}>
    <td>
      {policy.isAllowed("block_storage:volume_get", {}) ?
        <Link to={`/volumes/${volume.id}/show`}>
          <MyHighlighter search={searchTerm}>{volume.name}</MyHighlighter>
        </Link>
        :
        <MyHighlighter search={searchTerm}>{volume.name}</MyHighlighter>
      }
      <br/>
      <span className='info-text'><MyHighlighter search={searchTerm}>{volume.id}</MyHighlighter></span>
    </td>
    <td>{volume.availability_zone}</td>
    <td>{volume.description}</td>
    <td>{volume.size}</td>
    <td>
      {volume && volume.attachments && volume.attachments.length>0 &&
        volume.attachments.map((attachment,index) =>
          <div key={index}>
            {attachment.server_name ?
              <React.Fragment>
                <a href={`/${scope.domain}/${scope.project}/compute/instances/${attachment.server_id}`} data-modal={true}>{attachment.server_name}</a>
                &nbsp;on {attachment.device}
                <br/>
                <span className='info-text'>{attachment.server_id}</span>
              </React.Fragment>
              :
              attachment.server_id
            }
          </div>
        )
      }
    </td>
    <td><MyHighlighter search={searchTerm}>{volume.status}</MyHighlighter></td>
    <td className='snug'></td>
  </tr>
