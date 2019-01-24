import { OverlayTrigger, Tooltip } from 'react-bootstrap';

import { Unit } from '../../unit';
import { byUIString, t } from '../../utils';

const ResourceName = ({name, flavorData}) => {
  if (!flavorData.primary || !flavorData.secondary) {
    return <div className='col-md-2 text-right'>{name}</div>;
  }

  let tooltip = <Tooltip id={`tooltip-${name}`} className='tooltip-no-break'>{flavorData.secondary}</Tooltip>;
  // TODO: line breaks make the .small.text-muted.flavor-data look ugly -- maybe place below bar like we had for .resource-error?
  return (
    <div className='col-md-2 text-right'>
      <OverlayTrigger overlay={tooltip} placement='right' delayShow={300} delayHide={150}><span>{name}</span></OverlayTrigger>
      <div className='small text-muted flavor-data'>{flavorData.primary}</div>
    </div>
  );
};

const ResourceError = (props) => (
  <p className='resource-error text-danger'>
    <i className='fa fa-lg fa-warning' />{' '}
    {props.children}
  </p>
);

const valueWithUnit = (value, unit) => {
  const title = unit.name !== '' ? `${value} ${unit.name}` : undefined;
  return <span className='value-with-unit' title={title}>{unit.format(value)}</span>;
};

export default class ProjectResource extends React.Component {
  state = {}

  renderBarContents(quota, usage, unit, isDanger) {
    //get some edge cases out of the way first
    if (quota == 0 && usage == 0) {
      return (
        <div className='progress-bar progress-bar-disabled has-label' style={{width:'100%'}}>
          No quota
        </div>
      );
    }

    let widthPerc = Math.round(1000 * (usage / quota)) / 10;
    //ensure that a non-zero-wide bar is at least somewhat visible
    if (usage > 0 && widthPerc < 0.5) {
      widthPerc = 0.5;
    }

    //special cases: yellow and red bars
    let className = 'progress-bar';
    if (isDanger) {
      className = 'progress-bar progress-bar-danger progress-bar-striped';
      widthPerc = 100;
    } else if (usage >= quota) {
      className = 'progress-bar progress-bar-warning';
      widthPerc = 100;
    }

    //when the label does not fit in the bar itself, place it next to it
    const label = (
      <React.Fragment>
        {valueWithUnit(usage, unit)}/{valueWithUnit(quota, unit)}
      </React.Fragment>
    );
    const labelText = `${unit.format(usage)}/${unit.format(quota)}`;
    if (widthPerc > (2 * labelText.length)) {
      return (
        <div className={`${className} has-label`} style={{width:widthPerc+'%'}}>{label}</div>
      );
    } else {
      return <React.Fragment>
        <div className={className} style={{width:widthPerc+'%'}} />
        <div className='progress-bar progress-bar-empty has-label'>{label}</div>
      </React.Fragment>;
    }
  }

  renderBurstInfo(quota, usage, backendQuota, unit) {
    if (backendQuota <= quota) {
      return '';
    }

    const maxBurst = unit.format(backendQuota - quota);
    if (usage <= quota) {
      return `${maxBurst} burst available`;
    } else {
      const currBurst = unit.format(usage - quota);
      return `${currBurst}/${maxBurst} burst in use`;
    }
  }

  renderInfo(quota, usage, desiredBackendQuota, actualBackendQuota, unit) {
    let msg = null;
    if (usage > desiredBackendQuota) {
      msg = 'Usage exceeds backend quota. Please request more quota to fix.';
    } else if (desiredBackendQuota != actualBackendQuota) {
      msg = `Expected backend quota to be ${unit.format(desiredBackendQuota)}, but is ${unit.format(actualBackendQuota)}.`;
    } else {
      return this.renderBurstInfo(quota, usage, desiredBackendQuota, unit);
    }

    return (
      <p className='resource-error text-danger'>
        <i className='fa fa-lg fa-warning' />{' '}{msg}
      </p>
    );
  }

  renderEditControls() {
    const { editQuotaText, resource } = this.props;
    const { name: resourceName } = resource;

    return (
      <React.Fragment>
        <div className='col-md-2 edit-quota-input'>
          <input className='form-control input-sm' type='text' value={editQuotaText} onChange={(e) => this.props.handleInput(resourceName, e.target.value)} />
        </div>
      </React.Fragment>
    );
  }

  render() {
    const displayName = t(this.props.resource.name);
    const flavorData = this.props.flavorData[displayName] || {};

    const { quota, usage, backendQuota, unit: unitName } = this.props.resource;
    const { enabled: hasBursting, multiplier: burstMultiplier } =
      this.props.metadata.bursting || {};

    const desiredBackendQuota =
      hasBursting ? Math.floor(quota * (1 + burstMultiplier)) : quota;
    const actualBackendQuota = backendQuota == null ? desiredBackendQuota : backendQuota;
    const isDanger = usage > desiredBackendQuota || desiredBackendQuota != actualBackendQuota;

    const unit = new Unit(unitName || "");

    return (
      <div className='row'>
        <ResourceName name={displayName} flavorData={flavorData} />
        <div className='col-md-5'>
          <div className='progress'>
            {this.renderBarContents(quota, usage, unit, isDanger)}
          </div>
        </div>
        {this.props.editQuotaValue
          ? this.renderEditControls()
          : <div className='col-md-5'>
              {this.renderInfo(quota, usage, desiredBackendQuota, actualBackendQuota, unit)}
            </div>
        }
      </div>
    );
  }
}
