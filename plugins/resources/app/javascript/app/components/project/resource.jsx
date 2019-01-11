import { OverlayTrigger, Tooltip } from 'react-bootstrap';

import { Unit } from '../../unit';
import { byUIString, t, formatLargeInteger } from '../../utils';

const ResourceName = ({name, flavorData}) => {
  if (!flavorData.primary || !flavorData.secondary) {
    return <div className='col-md-2'>{name}</div>;
  }

  let tooltip = <Tooltip id={`tooltip-${name}`} className='tooltip-no-break'>{flavorData.secondary}</Tooltip>;
  return (
    <div className='col-md-2'>
      <OverlayTrigger overlay={tooltip} placement='right' delayShow={300} delayHide={150}><span>{name}</span></OverlayTrigger>
      <div><small className='text-muted'>{flavorData.primary}</small></div>
    </div>
  );
};

const ResourceError = (props) => (
  <p className='resource-error text-danger'>
    <i className='fa fa-lg fa-warning' />{' '}
    {props.children}
  </p>
);

const UnitValue = ({ unit, value }) => {
  if (unit === '' || !unit) {
    return <span className='value-with-unit'>{formatLargeInteger(value)}</span>;
  }

  const formattedValue = (new Unit(unit)).format(value);
  return <span className='value-with-unit' title={`${value} ${unit}`}>{formattedValue}</span>;
};

export default class ProjectResource extends React.Component {
  state = {}

  renderBarContents(quota, usage, desiredBackendQuota) {
    //get some edge cases out of the way first
    if (quota == 0 && usage == 0) {
      return <div className='progress-bar progress-bar-disabled' style={{width:'100%'}} />;
    }
    if (usage > desiredBackendQuota) {
      return <div className='progress-bar progress-bar-danger progress-bar-striped' style={{width:'100%'}} />;
    }

    //common case: quota, usage <= desiredBackendQuota
    //NOTE: 100% of the bar's width is always equal to desiredBackendQuota.
    const usageWidthPerc = 100 * (usage / desiredBackendQuota);
    const quotaWidthPerc = 100 * (quota / desiredBackendQuota);
    const bars = [
      <div key='usage'
        className={usage >= quota ? 'progress-bar progress-bar-warning' : 'progress-bar'}
        style={{width: usageWidthPerc + '%'}}
      />
    ];
    //bridge the gap between usage and the shaded bursting area
    if (usageWidthPerc < quotaWidthPerc - 0.01) {
      bars.push(<div key='empty'
        className='progress-bar progress-bar-empty'
        style={{width: (quotaWidthPerc - usageWidthPerc) + '%'}}
      />);
    }
    //shade the area that can only be reached by bursting
    if (quotaWidthPerc < 99.99) {
      bars.push(<div key='burst'
        className='progress-bar progress-bar-burst'
        style={{width: (100 - quotaWidthPerc) + '%'}}
      />);
    }

    return bars;
  }

  render() {
    const displayName = t(this.props.resource.name);
    const flavorData = this.props.flavorData[displayName] || {};

    const { quota, usage, backendQuota, unit } = this.props.resource || {};
    const { enabled: hasBursting, multiplier: burstMultiplier } =
      this.props.metadata.bursting || {};

    const desiredBackendQuota =
      hasBursting ? Math.floor(quota * (1 + burstMultiplier)) : quota;
    const actualBackendQuota = backendQuota == null ? desiredBackendQuota : backendQuota;

    //TODO: value formatting in ResourceError
    //TODO: value formatting in columns
    return (
      <div className='row'>
        <ResourceName name={displayName} flavorData={flavorData} />
        <div className='col-md-6'>
          <div className='progress'>
            {this.renderBarContents(quota, usage, desiredBackendQuota)}
          </div>
          {usage > desiredBackendQuota && <ResourceError>
            Usage ({usage}) exceeds expected backend quota ({desiredBackendQuota}).
          </ResourceError>}
          {desiredBackendQuota != actualBackendQuota && <ResourceError>
            Expected backend quota to be {desiredBackendQuota}, but is {actualBackendQuota}.
          </ResourceError>}
        </div>
        <div className='col-md-1 text-right'><UnitValue unit={unit} value={usage} /></div>
        <div className='col-md-1 text-right'><UnitValue unit={unit} value={quota} /></div>
      </div>
    );
  }
}
