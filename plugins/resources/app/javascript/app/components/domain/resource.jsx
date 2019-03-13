import { Link } from 'react-router-dom';

import { Unit } from '../../unit';
import { t } from '../../utils';
import ResourceBar from '../../components/resource_bar';
import ResourceEditor from '../../components/resource_editor';
import ResourceName from '../../components/resource_name';

export default (props) => {
  const displayName = t(props.resource.name);
  const flavorData = props.flavorData[displayName] || {};

  const { name: resourceName, quota: originalQuota, projects_quota: projectsQuota, backend_quota: backendQuota, unit: unitName } = props.resource;

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

  return (
    <div className={isEditing && props.edit.error ? 'row has-error' : 'row'}>
      <ResourceName name={displayName} flavorData={flavorData} />
      <div className={isEditing ? 'col-md-4' : 'col-md-5'}>
        <ResourceBar
          capacity={quota} fill={projectsQuota} unitName={unitName}
          isDanger={false} isEditing={isEditing} scopeData={props.scopeData} />
      </div>
      {isEditing
        ? <ResourceEditor {...editorProps} />
        : <div className='col-md-5'>
            { props.canEdit && <Link to={`/details/${props.categoryName}/${resourceName}`} className='btn btn-primary btn-sm btn-quota-details'>Show projects</Link> }
          </div>
      }
    </div>
  );
}
