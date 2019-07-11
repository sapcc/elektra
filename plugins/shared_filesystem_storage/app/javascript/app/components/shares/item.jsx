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

//TODO: use Unit class from plugins/resources
const byteUnits = [ 'B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB' ];
const displayBytes = (value) => {
  let index = 0;
  while (value > 1024) {
    value = value / 1024;
    index++;
  }
  value = Math.round(value * 100) / 100;
  return `${value} ${byteUnits[index]}`;
};


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

  renderUtilization() {
    const { data, isFetching, wasRequested } = this.props.utilization;
    if (!wasRequested) {
      return;
    }
    if (isFetching) {
      return <div className='progress'>
        <div className='progress-bar progress-bar-empty'>
          <span className='spinner' /> Loading...
        </div>
      </div>;
    }
    if (data == null) {
      return <div className='progress'>
        <div className='progress-bar progress-bar-empty'>
          Unknown
        </div>
      </div>;
    }

    const snapReserveBytes = data.size_reserved_by_snapshots || 0;
    const shareSizeBytes   = (data.size_total || 0) + snapReserveBytes;

    const shareUsedBytes = data.size_used || 0;
    const shareUsedPerc  = 100 * (shareUsedBytes / shareSizeBytes);
    const shareTooltip   = `${displayBytes(shareUsedBytes)} used by files`;

    const snapUsedBytes    = data.size_used_by_snapshots || 0;
    const snapDisplayBytes = Math.max(snapUsedBytes, snapReserveBytes);
    const snapDisplayPerc  = 100 * (snapDisplayBytes / shareSizeBytes);
    const snapTooltip      = (snapUsedBytes > snapReserveBytes)
      ? `${displayBytes(snapDisplayBytes)} used by snapshots`
      : `${displayBytes(snapDisplayBytes)} reserved for snapshots`;

    const tooltip = <Tooltip id={`utilizationTooltip-${this.props.share.id}`}>
      <nobr>{shareTooltip}</nobr><br/><nobr>{snapTooltip}</nobr>
    </Tooltip>;

    return (
      <OverlayTrigger overlay={tooltip} placement='top' delayShow={300} delayHide={150}>
        <div className='progress'>
          <div className='progress-bar' style={{width: shareUsedPerc + '%'}} />
          <div className='progress-bar progress-bar-info' style={{width: snapDisplayPerc + '%'}} />
        </div>
      </OverlayTrigger>
    );
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
        <td className='has-share-utilization'>
          {this.renderUtilization()}
          {share.size || 0} GiB
        </td>
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
