import { Link } from 'react-router-dom';
import { policy } from 'policy';

export default class SnapshotItem extends React.Component {
  constructor(props){
  	super(props);
    this.startPolling = this.startPolling.bind(this)
    this.stopPolling = this.stopPolling.bind(this)
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    // stop polling if status has changed from creating to something else
    if (nextProps.snapshot.status!='creating') this.stopPolling()
  }

  componentDidMount() {
    if (this.props.snapshot.status=='creating') this.startPolling()
  }

  componentWillUnmount() {
    // stop polling on unmounting
    this.stopPolling()
  }

  startPolling(){
    this.polling = setInterval(() =>
      this.props.reloadSnapshot(this.props.snapshot.id), 10000
    )
  }

  stopPolling() {
    clearInterval(this.polling)
  }

  render(){
    let {snapshot, share, handleDelete} = this.props

    return(
      <tr className={ (snapshot.isFetching || snapshot.isDeleting) ? 'updating' : ''}>
        <td>
          <Link to={`/snapshots/${snapshot.id}/show`}>{snapshot.name || snapshot.id}</Link>
          {snapshot.name &&
            <React.Fragment>
              <br/>
              <span className='info-text'>{snapshot.id}</span>
            </React.Fragment>
          }
        </td>
        <td>
          { share ? (
            <div>{share.name}
              <br/>
              <span className='info-text'>{snapshot.share_id}</span>
            </div>
          ) : (
            snapshot.share_id
          )}
        </td>

        <td>{(snapshot.size || 0) + ' GB'}</td>
        <td>{snapshot.status=='creating' && <span className='spinner'/>} {snapshot.status}</td>
        <td className="snug">
          { (policy.isAllowed("shared_filesystem_storage:snapshot_delete") ||
             policy.isAllowed("shared_filesystem_storage:snapshot_update")) &&

            <div className='btn-group'>
              <button className="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">
                <i className='fa fa-cog'></i>
              </button>
              <ul className='dropdown-menu dropdown-menu-right' role="menu">
                { policy.isAllowed("shared_filesystem_storage:snapshot_delete") && snapshot.status!='creating' &&
                  <li><a href='#' onClick={ (e) => { e.preventDefault(); handleDelete(snapshot.id) } }>Delete</a></li>
                }
                { policy.isAllowed("shared_filesystem_storage:snapshot_update") &&
                  <li><Link to={`/snapshots/${snapshot.id}/edit`}>Edit</Link></li>
                }
                <li>
                  <Link to={`/snapshots/${snapshot.id}/error-log`}>Error Log</Link>
                </li>
              </ul>
            </div>
          }
        </td>
      </tr>
    )
  }
}
