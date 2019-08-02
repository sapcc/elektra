import { DataTable } from 'lib/components/datatable';

import { t } from '../../utils';

const columns = [
  { key: 'id', label: 'Project',
    sortStrategy: 'text', sortKey: props => props.project.name || '' },
  { key: 'config', label: 'Configuration' },
  { key: 'ajax_indicator', label: '' },
];

const ProjectConfigurationRow = ({ project, config, assetType }) => {
  return (
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
        ) : config.data[assetType] ? (
          <em>Custom configuration (configured via API)</em>
        ) : (
          <div className='text-muted'>Autoscaling not enabled</div>
        )}
      </td>
      <td></td>
    </tr>
  );
};

export default class AutoscalingView extends React.Component {
  state = {
    currentFullResource: '',
  }

  handleSelect(fullResource) {
    this.setState({ ...this.state, currentFullResource: fullResource });
  }

  renderRows() {
    const { autoscalableSubscopes, projectConfigs } = this.props;

    const [ srvType, resName ] = this.state.currentFullResource.split('/');
    const assetType = `project-quota:${srvType}:${resName}`;

    const projects = [ ...autoscalableSubscopes[srvType][resName] ];
    projects.sort((a,b) => a.name.localeCompare(b.name));

    return projects.map(project => (
      <ProjectConfigurationRow
        key={project.id}
        project={project}
        config={projectConfigs[project.id] || { isFetching: true }}
        assetType={assetType}
      />
    ));
  }

  render() {
    const { autoscalableSubscopes, projectConfigs } = this.props;
    const { currentFullResource } = this.state;

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
        <select className='form-control' onChange={(e) => this.handleSelect(e.target.value)} value={currentFullResource}>
          {currentFullResource == '' && <option value=''>-- Select a resource --</option>}
          {options.map(opt => (
            <option key={opt.key} value={opt.key}>{opt.label}</option>
          ))}
        </select>
        {currentFullResource != '' && (
          <DataTable columns={columns}>{this.renderRows()}</DataTable>
        )}
      </React.Fragment>
    );
  }
}
