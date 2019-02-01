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

  onInputKeyPress(e) {
    if (e.key == 'Enter') {
      this.props.triggerParseInputs();
    }
    //continue handling the key-press event in the regular manner
    return true;
  }

  renderBarContents(quota, usage, unit, isDanger, isEditing) {
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
    } else if (usage >= quota) {
      className = 'progress-bar progress-bar-warning';
    }
    if (widthPerc > 100) {
      widthPerc = 100;
    }

    //when the label does not fit in the bar itself, place it next to it (we take `isEditing` into account here because then the bar's length is only 60% of the original)
    const label = (
      <React.Fragment>
        {valueWithUnit(usage, unit)}/{valueWithUnit(quota, unit)}
      </React.Fragment>
    );
    const labelText = `${unit.format(usage)}/${unit.format(quota)}`;
    const lengthMultiplier = isEditing ? 3.5 : 2;
    if (widthPerc > (lengthMultiplier * labelText.length)) {
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

  renderInfo(quota, usage, usableQuota, actualBackendQuota, unit) {
    let msg = null;
    if (usage > usableQuota) {
      msg = 'Usage exceeds backend quota. Please request more quota to fix.';
    } else if (usableQuota != actualBackendQuota) {
      msg = `Expected backend quota to be ${unit.format(usableQuota)}, but is ${unit.format(actualBackendQuota)}.`;
    } else {
      return this.renderBurstInfo(quota, usage, usableQuota, unit);
    }

    return (
      <p className='resource-error text-danger'>
        <i className='fa fa-lg fa-warning' />{' '}{msg}
      </p>
    );
  }

  renderEditControls() {
    const { isFollowing } = this.props;
    const { text: editQuotaText, error: editError } = this.props.edit;
    const { name: resourceName, unit: unitName, scales_with: scalesWith } = this.props.resource;

    let errorMessage = undefined;
    switch (editError) {
      case 'syntax':
        errorMessage = unitName ?
          'Need a value like "1.2 TiB" or "50g".' :
          "Need an integer number.";
        break;
      case 'fractional-value':
        errorMessage = unitName ?
          `Need an integer number of ${unitName}.` :
          "Need an integer number.";
        break;
      case 'overspent':
        errorMessage = 'Must be more than current usage.';
        break;
    }

    let message = undefined;
    if (errorMessage) {
      message = <div className='col-md-4 text-danger'>{errorMessage}</div>;
    } else if (isFollowing) {
      message = <div className='col-md-4'>Adds {scalesWith.factor} per extra {t(scalesWith.resource_name+'_single')}</div>;
    }

    return (
      <React.Fragment>
        <div className='col-md-2 edit-quota-input'>
          <input
            className='form-control input-sm' type='text' value={editQuotaText}
            onChange={(e) => this.props.handleInput(resourceName, e.target.value)}
            onBlur={(e) => { this.props.triggerParseInputs(); return true; }}
            onMouseOut={(e) => { this.props.triggerParseInputs(); return true; }}
            onKeyPress={(e) => this.onInputKeyPress(e)}
            disabled={isFollowing}
          />
        </div>
        {message}
      </React.Fragment>
    );
  }

  render() {
    const displayName = t(this.props.resource.name);
    const flavorData = this.props.flavorData[displayName] || {};

    const { quota: originalQuota, usage, usable_quota: usableQuota, backend_quota: backendQuota, unit: unitName } = this.props.resource;
    const { enabled: hasBursting, multiplier: burstMultiplier } =
      this.props.metadata.bursting || {};

    //during editing, allow the parent form to override the displayed quota value
    const isEditing = this.props.edit ? true : false;
    const quota = isEditing ? this.props.edit.value : originalQuota;

    const actualBackendQuota = backendQuota == null ? usableQuota : backendQuota;
    const isDanger = usage > usableQuota || usableQuota != actualBackendQuota;

    const unit = new Unit(unitName || "");

    return (
      <div className={isEditing && this.props.edit.error ? 'row has-error' : 'row'}>
        <ResourceName name={displayName} flavorData={flavorData} />
        <div className={isEditing ? 'col-md-4' : 'col-md-5'}>
          <div className='progress'>
            {this.renderBarContents(quota, usage, unit, isDanger, isEditing)}
          </div>
        </div>
        {isEditing
          ? this.renderEditControls()
          : <div className='col-md-5'>
              {this.renderInfo(quota, usage, usableQuota, actualBackendQuota, unit)}
            </div>
        }
      </div>
    );
  }
}
