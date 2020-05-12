import { Unit } from '../../unit';
import { t } from '../../utils';
import ResourceBar from '../../components/resource_bar';
import ResourceEditor from '../../components/resource_editor';
import ResourceName from '../../components/resource_name';

export default class ProjectResource extends React.Component {
  state = {}

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

  render() {
    const displayName = t(this.props.resource.name);
    const flavorData = this.props.flavorData[displayName] || {};

    const { quota: originalQuota, usage, usable_quota: usableQuota, backend_quota: backendQuota, unit: unitName } = this.props.resource;

    //during editing, allow the parent form to override the displayed quota value
    const isEditing = this.props.edit ? true : false;
    const quota = isEditing ? this.props.edit.value : originalQuota;

    const actualBackendQuota = backendQuota == null ? usableQuota : backendQuota;
    const isDanger = usage > usableQuota || usableQuota != actualBackendQuota;

    const unit = new Unit(unitName || "");

    //The <ResourceEditor/> gets most of our props forwarded verbatim.
    const editorProps = {
      edit:      this.props.edit,
      resource:  this.props.resource,
      disabled:  this.props.disabled,
      scopeData: this.props.scopeData,
      handleInput:         this.props.handleInput,
      handleResetFollower: this.props.handleResetFollower,
      triggerParseInputs:  this.props.triggerParseInputs,
    };

    return (
      <div className={isEditing && this.props.edit.error ? 'row has-error' : 'row'}>
        <ResourceName name={displayName} flavorData={flavorData} />
        <div className={isEditing ? 'col-md-4' : 'col-md-5'}>
          <ResourceBar
            capacity={quota} fill={usage} unitName={unitName}
            isDanger={isDanger} showsCapacity={false} />
        </div>
        {isEditing
          ? <ResourceEditor {...editorProps} />
          : <div className='col-md-5'>
              {this.renderInfo(quota, usage, usableQuota, actualBackendQuota, unit)}
            </div>
        }
      </div>
    );
  }
}
