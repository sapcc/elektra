import { DataTable } from 'lib/components/datatable';
import { AutoscalingConfigItem, parseConfig } from './config_item';

import { t } from '../../utils';

const columns = [
  { key: 'id', label: 'Project',
    sortStrategy: 'text', sortKey: props => props.project.name || '' },
  { key: 'config', label: 'Configuration' },
  { key: 'ajax_indicator', label: '' },
];

export default class AutoscalingConfig extends React.Component {
  state = {
    currentFullResource: '',
    editValues: null,
  }

  handleSelect(fullResource) {
    this.setState({
      ...this.state,
      currentFullResource: fullResource,
      editValues: null,
    });
  }

  startEditing() {
    const [ srvType, resName ] = this.state.currentFullResource.split('/');
    const assetType = `project-quota:${srvType}:${resName}`;

    const { projectConfigs } = this.props;
    const editValues = {};
    for (const projectID in projectConfigs) {
      const parsed = parseConfig(projectConfigs[projectID][assetType]);
      if (!parsed.custom) {
        editValues[projectID] = parsed.value === null ? '' : parsed.value;
      }
    }

    this.setState({
      ...this.state,
      editValues,
    });
  }

  handleEditValue(projectID, newValue) {
    this.setState({
      ...this.state,
      editValues: { ...this.state.editValues, [projectID]: newValue },
    });
  }

  stopEditing() {
    this.setState({
      ...this.state,
      editValues: null,
    });
  }

  save() {
    //TODO
  }

  renderRows() {
    const { autoscalableSubscopes, projectConfigs } = this.props;

    const [ srvType, resName ] = this.state.currentFullResource.split('/');
    const assetType = `project-quota:${srvType}:${resName}`;

    const projects = [ ...autoscalableSubscopes[srvType][resName] ];
    projects.sort((a,b) => a.name.localeCompare(b.name));

    const { editValues } = this.state;
    const editorProps = {
      handleEditValue: this.handleEditValue.bind(this),
    };

    return projects.map(project => (
      <AutoscalingConfigItem
        key={project.id}
        project={project}
        config={projectConfigs[project.id] || { isFetching: true }}
        assetType={assetType}
        editValue={editValues ? editValues[project.id] : null}
        {...editorProps}
      />
    ));
  }

  render() {
    const { autoscalableSubscopes, projectConfigs } = this.props;
    const { currentFullResource, editValues } = this.state;

    //assemble options for <select> box
    const options = [];
    for (const srvType in autoscalableSubscopes) {
      for (const resName in autoscalableSubscopes[srvType]) {
        const assetType = `project-quota:${srvType}:${resName}`;
        let enabledCount = 0;
        for (const projectID in projectConfigs) {
          if (projectConfigs[projectID].data == null) {
            enabledCount = '?';
            break;
          }
          if (projectConfigs[projectID].data[assetType]) {
            enabledCount++;
          }
        }

        const subscopes = autoscalableSubscopes[srvType][resName];
        if (subscopes.length > 0) {
          options.push({
            key: `${srvType}/${resName}`,
            label: `${t(srvType)} > ${t(resName)} (${enabledCount}/${subscopes.length})`,
          });
        }
      }
    }
    options.sort((a, b) => a.label.localeCompare(b.label));

    return (
      <React.Fragment>
        <p>
          <select className='form-control' onChange={(e) => this.handleSelect(e.target.value)} value={currentFullResource}>
            {currentFullResource == '' && <option value=''>-- Select a resource --</option>}
            {options.map(opt => (
              <option key={opt.key} value={opt.key}>{opt.label}</option>
            ))}
          </select>
        </p>
        {currentFullResource != "" && (
          editValues ? (
            <p>
              <button className='btn btn-primary' onClick={() => this.save()}>Save</button>
              {' '}
              <button className='btn btn-link' onClick={() => this.stopEditing()}>Cancel</button>
            </p>
          ) : (
            <p>
              <button className='btn btn-primary' onClick={() => this.startEditing()}>Edit this table</button>
            </p>
          )
        )}
        {currentFullResource != '' && (
          <DataTable columns={columns}>{this.renderRows()}</DataTable>
        )}
      </React.Fragment>
    );
  }
}
