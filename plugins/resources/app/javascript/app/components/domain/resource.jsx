import { Link } from 'react-router-dom';

import { Unit, valueWithUnit } from '../../unit';
import { t } from '../../utils';
import ResourceBar from '../../components/resource_bar';
import ResourceEditor from '../../components/resource_editor';
import ResourceName from '../../components/resource_name';

export default (props) => {
  const displayName = t(props.resource.name);
  const flavorData = props.flavorData[displayName] || {};

  const { name: resourceName, quota: originalQuota, projects_quota: projectsQuota, backend_quota: backendQuota, usage, burst_usage: burstUsage, unit: unitName } = props.resource;

  //during editing, allow the parent form to override the displayed quota value
  const isEditing = props.edit ? true : false;
  const quota = isEditing ? props.edit.value : originalQuota;

  const unit = new Unit(unitName || "");

  //The <ResourceEditor/> gets most of our props forwarded verbatim.
  const editorProps = {
    edit:      props.edit,
    resource:  props.resource,
    disabled:  props.disabled,
    scopeData: props.scopeData,
    handleInput:         props.handleInput,
    handleResetFollower: props.handleResetFollower,
    triggerParseInputs:  props.triggerParseInputs,
  };

  //inside <DetailsModal/>, the resource name is replaced with a caption
  //depending on which fill is shown
  const caption = props.captionOverride
    ? <div className='col-md-2'>{props.captionOverride}</div>
    : <ResourceName name={displayName} flavorData={flavorData} />;
  //inside <DetailsModal/>, the "Resource usage" bar indicates the actual
  //resource usage rather than the quota usage of projects
  const fillProps = { fill: projectsQuota };
  if (props.showUsage) {
    fillProps.fill = usage;
    if (burstUsage > 0) {
      fillProps.labelOverride = (
        <React.Fragment>
          {valueWithUnit(usage - burstUsage, unit)} + {valueWithUnit(burstUsage, unit)} burst
        </React.Fragment>
      );
    }
  }

  return (
    <div className={isEditing && props.edit.error ? 'row has-error' : 'row'}>
      {caption}
      <div className={props.wide ? 'col-md-9' : isEditing ? 'col-md-4' : 'col-md-5'}>
        <ResourceBar
          capacity={quota} {...fillProps} unitName={unitName}
          isDanger={false} scopeData={props.scopeData} />
      </div>
      {!props.wide && (
        isEditing
          ? <ResourceEditor {...editorProps} />
          : <div className='col-md-5'>
              { props.canEdit && <Link to={`/details/${props.categoryName}/${resourceName}`} className='btn btn-primary btn-sm btn-quota-details'>Show projects</Link> }
            </div>
      )}
    </div>
  );
}
