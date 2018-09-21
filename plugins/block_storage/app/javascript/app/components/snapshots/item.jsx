import {Link} from 'react-router-dom';
import { scope } from 'ajax_helper';
import { Highlighter } from 'react-bootstrap-typeahead';

const MyHighlighter = ({search,children}) => {
  if(!search || !children) return children
  return <Highlighter search={search}>{children+''}</Highlighter>
}

export default ({snapshot, searchTerm}) =>
  <tr className={`state-${snapshot.status}`}>
    <td>
      {policy.isAllowed("block_storage:snapshot_get", {}) ?
        <Link to={`/snapshots/${snapshot.id}/show`}>
          <MyHighlighter search={searchTerm}>{snapshot.name}</MyHighlighter>
        </Link>
        :
        <MyHighlighter search={searchTerm}>{snapshot.name}</MyHighlighter>
      }
      <br/>
      <span className='info-text'><MyHighlighter search={searchTerm}>{snapshot.id}</MyHighlighter></span>
    </td>
    <td><MyHighlighter search={searchTerm}>{snapshot.description}</MyHighlighter></td>
    <td><MyHighlighter search={searchTerm}>{snapshot.size}</MyHighlighter></td>
    <td>
      {snapshot.volume_name ?
        <React.Fragment>
          <Link to={`/snapshots/volumes/${snapshot.volume_id}/show`}>{snapshot.volume_name}</Link>
          <br/>
          <span className='info-text'>{snapshot.volume_id}</span>
        </React.Fragment>
        :
        snapshot.volume_id
      }
    </td>
    <td><MyHighlighter search={searchTerm}>{snapshot.status}</MyHighlighter></td>
    <td className='snug'></td>
  </tr>
