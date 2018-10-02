import { Link } from 'react-router-dom';
import { policy } from 'policy';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import * as constants from '../../constants';

class RuleTooltip extends React.Component {
  render() {
    let al = this.props.rule.access_level
    let tooltip = <Tooltip id='ruleTooltip'>
      Access Level: {al=='ro' ? 'read only' : (al=='rw' ? 'read/write' : al)}
    </Tooltip>;

    return (
      <OverlayTrigger
        overlay={tooltip}
        placement="top"
        delayShow={300}
        delayHide={150}
      >
        {this.props.children}
      </OverlayTrigger>
    );
  }
}


export default class ShareItem extends React.Component {
  constructor(props){
    super(props);
    this.startPolling = this.startPolling.bind(this)
    this.stopPolling = this.stopPolling.bind(this)
  }

  componentWillReceiveProps(nextProps) {
    // stop polling if status has changed from creating to something else
    this.pendignState(nextProps) ? this.startPolling() : this.stopPolling()
    nextProps.loadShareRulesOnce(nextProps.share.id)
  }

  componentDidMount() {
    if (this.pendignState()) this.startPolling()
    this.props.loadShareRulesOnce(this.props.share.id)
  }

  componentWillUnmount() {
    // stop polling on unmounting
    this.stopPolling()
  }

  startPolling = () => {
    // do not create a new polling interval if already polling
    if(this.polling) return;
    this.polling = setInterval(() =>
      this.props.reloadShare(this.props.share.id), 5000
    )
  }

  stopPolling = () => {
    clearInterval(this.polling)
    this.polling = null
  }

  pendignState = (props = this.props) => {
    return constants.SHARE_PENDING_STATUS.indexOf(props.share.status) >= 0
  }

  render(){
    let { share, shareNetwork, shareRules, handleDelete, handleForceDelete } = this.props

    return(
      <tr className={ share.isDeleting ? 'updating' : ''}>
        <td>
          <Link to={`/shares/${share.id}/show`}>{share.name || share.id}</Link>
        </td>
        <td>{share.availability_zone}</td>
        <td>{share.share_proto}</td>
        <td>{(share.size || 0) + ' GB'}</td>
        <td>
          { share.status == 'creating' &&
            <span className='spinner'></span>
          }
          {share.status}
        </td>
        <td>
          { shareNetwork ? (
            <span>
              {shareNetwork.name}
              { shareNetwork.cidr &&
                <span className='info-text'>{" "+shareNetwork.cidr}</span>
              }
              { shareRules &&
                (
                  shareRules.isFetching ? (
                    <span className='spinner'></span>
                  ) : (
                    <span>
                      <br/>
                      { shareRules.items.map( (rule) =>
                        <RuleTooltip key={rule.id} rule={rule}>
                          <small
                            className={`${rule.access_level == 'rw' ? 'text-success' : 'text-info'}`}>
                            <i className={`fa fa-fw fa-${rule.access_level == 'rw' ? 'pencil-square' : 'eye'}`}/>
                            {rule.access_to}
                          </small>
                        </RuleTooltip>

                      )}
                    </span>
                  )
                )}
            </span>) : (
            <span className='spinner'></span>
          )}
        </td>
        <td className="snug">
          { (policy.isAllowed("shared_filesystem_storage:share_delete") ||
             policy.isAllowed("shared_filesystem_storage:share_update")) &&

            <div className='btn-group'>
              <button
                className="btn btn-default btn-sm dropdown-toggle"
                type="button"
                data-toggle="dropdown"
                aria-expanded="true">
                <i className='fa fa-cog'></i>
              </button>
              <ul className='dropdown-menu dropdown-menu-right' role="menu">
                { policy.isAllowed("shared_filesystem_storage:share_delete") &&
                  <li><a href='#' onClick={ (e) => { e.preventDefault(); handleDelete(share.id) } }>Delete</a></li>
                }
                { policy.isAllowed("shared_filesystem_storage:share_force_delete") &&
                  <li><a href='#' onClick={ (e) => { e.preventDefault(); handleForceDelete(share.id) } }>Force Delete</a></li>
                }
                { policy.isAllowed("shared_filesystem_storage:share_update") && !this.pendignState() &&
                  <React.Fragment>
                    <li><Link to={`/shares/${share.id}/edit`}>Edit</Link></li>
                    <li><Link to={`/shares/${share.id}/edit-size`}>Extend / Shrink</Link></li>
                  </React.Fragment>
                }
                { policy.isAllowed("shared_filesystem_storage:share_update") && share.status=='available' &&
                  <li>
                    <Link to={`/shares/${share.id}/snapshots/new`}>Create Snapshot</Link>
                  </li>
                }
                { policy.isAllowed("shared_filesystem_storage:share_update") && share.status=='available' &&
                  <li>
                    <Link to={`/shares/${share.id}/access-control`}>Access Control</Link>
                  </li>
                }
                { policy.isAllowed("shared_filesystem_storage:share_reset_status") &&
                  <li>
                    <Link to={`/shares/${share.id}/reset-status`}>Reset Status</Link>
                  </li>
                }
                <li>
                  <Link to={`/shares/${share.id}/error-log`}>Error Log</Link>
                </li>
              </ul>
            </div>
          }
        </td>
      </tr>
    )
  }
}
