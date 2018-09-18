import {Link} from 'react-router-dom';
import { scope } from 'ajax_helper';

export default ({snapshot}) =>
  <tr className={`state-${snapshot.status}`}>
    <td>
      {policy.isAllowed("block_storage:snapshot_get", {}) ?
        <Link to={`/snapshots/${snapshot.id}/show`}>{snapshot.name}</Link>
        :
        snapshot.name
      }
      <br/>
      <span className='info-text'>{snapshot.id}</span>
    </td>
    <td>{snapshot.description}</td>
    <td>{snapshot.size}</td>
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
    <td>{snapshot.status}</td>
    <td className='snug'></td>
  </tr>
