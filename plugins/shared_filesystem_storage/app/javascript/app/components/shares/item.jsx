import { Link } from 'react-router-dom';
import { policy } from 'policy';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import * as constants from '../../constants';
import ShareActions from './actions';

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
    this.pendingState(nextProps) ? this.startPolling() : this.stopPolling()
    nextProps.loadShareRulesOnce(nextProps.share.id)
  }

  componentDidMount() {
    if (this.pendingState()) this.startPolling()
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

  pendingState = (props = this.props) => {
    return constants.isShareStatusPending(props.share.status);
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
          <ShareActions
            share={share} isPending={this.pendingState()}
            parentView='shares'
            handleDelete={handleDelete} handleForceDelete={handleForceDelete}
          />
        </td>
      </tr>
    )
  }
}
