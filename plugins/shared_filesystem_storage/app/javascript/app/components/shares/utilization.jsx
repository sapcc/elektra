import { OverlayTrigger, Tooltip } from 'react-bootstrap';

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

export default class ShareUtilization extends React.Component {
  render() {
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

    const bar = (
      <div className='progress'>
        <div className='progress-bar' style={{width: shareUsedPerc + '%'}} />
        <div className='progress-bar progress-bar-info' style={{width: snapDisplayPerc + '%'}} />
      </div>
    );

    if (this.props.compact) {
      const tooltip = <Tooltip id={`utilizationTooltip-${this.props.shareID}`}>
        <nobr>{shareTooltip}</nobr><br/><nobr>{snapTooltip}</nobr>
      </Tooltip>;
      return (
        <OverlayTrigger overlay={tooltip} placement='top' delayShow={300} delayHide={150}>
          {bar}
        </OverlayTrigger>
      );
    } else {
      return (
        <React.Fragment>
          {bar}
          <div className='small'>{shareTooltip}, {snapTooltip}</div>
        </React.Fragment>
      );
    }
  }
}
