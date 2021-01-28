import { Unit } from '../../unit';
import {parseConfig} from './helper'

const renderConfigUI = ({ projectID, config, editValue, handleEditValue, unitName }) => {
  const unit = new Unit(unitName);
  const parsed = parseConfig(config);
  if (parsed.custom) {
    return <em>Custom configuration (applied via API)</em>;
  }

  if (editValue === null) {
    if (parsed.value === null) {
      return <div className='text-muted'>Autoscaling not enabled</div>;
    } else {
      const extraText = (parsed.value === 0)
        ? `(but at least ${unit.format(1)} free)`
        : '';
      return <span>Target <strong>{parsed.value}%</strong> free quota {extraText}</span>;
    }
  } else {
    return <span>
      Target{' '}
      <input type='text'
        className='form-control' style={{width:'auto',display:'inline'}}
        value={editValue}
        onChange={(e) => handleEditValue(projectID, e.target.value)}
      />
      {' '}% free quota (leave empty to disable)
    </span>;
  }
};

export const AutoscalingConfigItem = ({ project, config, assetType, ...editorProps }) => (
  <tr>
    <td className='col-md-4'>
      {project.name}
      <div className='small text-muted'>{project.id}</div>
    </td>
    <td className='col-md-8'>
      { config.isFetching ? (
        <div><span className='spinner'/> Loading...</div>
      ) : config.data == null ? (
        <div className='alert alert-error'>Could not load autoscaling configuration for project</div>
      ) : (
        renderConfigUI({
          projectID: project.id,
          config: config.data[assetType],
          ...editorProps,
        })
      )}
    </td>
    <td></td>
  </tr>
);


