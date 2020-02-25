import moment from 'moment';
import { Link } from 'react-router-dom';

import { Scope } from '../scope';
import { byUIString, byNameIn, t } from '../utils';
import Category from '../containers/category';
import AutoscalingTabs from './autoscaling/tabs';
import AvailabilityZoneOverview from '../containers/availability_zones/overview';
import Inconsistencies from '../containers/inconsistencies';
import ProjectSyncAction from '../components/project/sync_action';
import ResourceBar from './resource_bar';


export default class Overview extends React.Component {
  componentDidMount() {
    this.initCurrentArea(this.props);
  }
  componentWillReceiveProps(nextProps) {
    this.initCurrentArea(nextProps);
  }
  initCurrentArea(props) {
    //set hash route to first tab on startup
    const { currentArea } = props.match.params;
    const allAreas = this.getAllAreaNames(props);
    if (!currentArea || !allAreas.includes(currentArea)) {
      props.history.replace(`/${allAreas[0]}`);
    }
  }

  getAllAreaNames(props) {
    const areas = Object.keys(props.overview.areas).sort(byUIString);
    areas.push('availability_zones');

    const { canAutoscale, scopeData } = props;
    if (canAutoscale) {
      areas.push('autoscaling');
    }
    const scope = new Scope(scopeData);
    if (scope.isCluster()) {
      areas.push('inconsistencies');
    }
    return areas;
  }

  renderArea(currentArea) {
    const props = this.props;
    const scope = new Scope(props.scopeData);

    const { areas, categories, scrapedAt, minScrapedAt, maxScrapedAt } = props.overview;
    const currentServices = areas[currentArea];

    const currMinScrapedAt = currentServices
      .map(serviceType => minScrapedAt[serviceType])
      .filter(x => x !== undefined);
    const currMaxScrapedAt = currentServices
      .map(serviceType => maxScrapedAt[serviceType])
      .filter(x => x !== undefined);
    const currScrapedAt = currentServices
      .map(serviceType => scrapedAt[serviceType])
      .filter(x => x !== undefined);
    const minScrapedStr = moment.unix(Math.min(...currMinScrapedAt, ...currScrapedAt)).fromNow(true);
    const maxScrapedStr = moment.unix(Math.max(...currMaxScrapedAt, ...currScrapedAt)).fromNow(true);
    const ageDisplay = minScrapedStr == maxScrapedStr ? minScrapedStr : `between ${minScrapedStr} and ${maxScrapedStr}`;

    const syncActionProps = {
      scopeData: props.scopeData,
      syncStatus: props.syncStatus,
      syncProject: props.syncProject,
      pollRunningSyncProject: props.pollRunningSyncProject,
    };

    return (
      <React.Fragment>
        {currentServices.sort(byUIString).map(serviceType => (
          <React.Fragment key={serviceType}>
            {categories[serviceType].sort(byNameIn(serviceType)).map(categoryName => (
              <Category key={categoryName} categoryName={categoryName} flavorData={this.props.flavorData} scopeData={this.props.scopeData} canEdit={this.props.canEdit} />
            ))}
          </React.Fragment>
        ))}
        <div className='row'>
          <div className='col-md-6 col-md-offset-2'>
            Usage data last updated {ageDisplay} ago{' '}
            {props.canEdit && scope.isProject() &&
              <ProjectSyncAction {...syncActionProps} />}
          </div>
        </div>
      </React.Fragment>
    );
  }

  renderAvailabilityZoneTab() {
    const { flavorData } = this.props;
    const { bigVmResources } = this.props;
    return <div>
      <AvailabilityZoneOverview flavorData={flavorData} />;
      <h3>Available BigVM Resources</h3>
      <ResourceBar capacity={1 || 0} fill={0} showsCapacity={false} />
      { Object.keys(bigVmResources).sort().map( bigVmResourceName => 
         <div style={{marginBottom:"10px"}} key={bigVmResourceName} className="row">
          <div className="col-md-2 text-right"><span>{bigVmResourceName}</span></div>
          <div className="col-md-3 text-left"> 
            <div style={{marginBottom:"3px"}}>Memory <i className="fa fa-arrow-right "></i> {(bigVmResources[bigVmResourceName]["inventory"]["MEMORY_MB"]["max_unit"]/1024/1024).toFixed(2)}TB</div>
            <div style={{marginBottom:"3px"}}>VCPUs <i className="fa fa-arrow-right "></i> {bigVmResources[bigVmResourceName]["inventory"]["VCPU"]["max_unit"]}</div>
            <div style={{marginBottom:"3px"}}>Availability Zone <i className="fa fa-arrow-right "></i> {bigVmResources[bigVmResourceName]["availability_zone"]}</div>
          </div>
         </div>
      )}
    </div>
  }

  renderAutoscalingTab() {
    const { scopeData, canEdit } = this.props;
    return <AutoscalingTabs scopeData={scopeData} canEdit={canEdit} />;
  }

  renderInconsistenciesTab() {
    return <Inconsistencies/>;
  }

  render() {
    const allAreas = this.getAllAreaNames(this.props);
    let currentArea = this.props.match.params.currentArea;
    if (!currentArea || !allAreas.includes(currentArea)) {
      currentArea = allAreas[0];
    }

    const { canEdit, canAutoscale, scopeData } = this.props;
    const scope = new Scope(scopeData);

    let currentTab;
    switch (currentArea) {
      case 'availability_zones':
        currentTab = this.renderAvailabilityZoneTab();
        break;
      case 'autoscaling':
        currentTab = this.renderAutoscalingTab();
        break;
      case 'inconsistencies':
        currentTab = this.renderInconsistenciesTab();
        break;
      default:
        currentTab = this.renderArea(currentArea);
        break;
    }

    return (
      <React.Fragment>
        <nav className='nav-with-buttons'>
          <ul className='nav nav-tabs'>
            { allAreas.map(area => (
              <li key={area} role="presentation" className={currentArea == area ? "active" : ""}>
                <Link to={`/${area}`}>{t(area)}</Link>
              </li>
            ))}
          </ul>
          {canEdit && scope.isProject() && this.props.metadata.bursting !== null && <div className='nav-main-buttons'>
            <Link to={`/${currentArea}/settings`} className='btn btn-primary btn-sm'>Settings</Link>
          </div>}
        </nav>
        {currentTab}
      </React.Fragment>
    );
  }
}
