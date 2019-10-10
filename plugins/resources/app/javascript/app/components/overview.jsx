import moment from 'moment';
import { Link } from 'react-router-dom';

import { Scope } from '../scope';
import { byUIString, byNameIn, t } from '../utils';
import Category from '../containers/category';
import AutoscalingTabs from './autoscaling/tabs';
import AvailabilityZoneOverview from '../containers/availability_zones/overview';
import ProjectSyncAction from '../components/project/sync_action';

export default class Overview extends React.Component {
  state = {
    currentArea: null,
  }

  changeArea = (area) => {
    this.setState({...this.state, currentArea: area});
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
    return <AvailabilityZoneOverview flavorData={flavorData} />;
  }

  renderAutoscalingTab() {
    const { scopeData, canEdit } = this.props;
    return <AutoscalingTabs scopeData={scopeData} canEdit={canEdit} />;
  }

  render() {
    const allAreas = Object.keys(this.props.overview.areas).sort(byUIString)
    const currentArea = this.state.currentArea || allAreas[0];
    const { canEdit, canAutoscale, scopeData } = this.props;
    const scope = new Scope(scopeData);

    const tabs = [ ...allAreas ];
    if (scope.isCluster() || window.location.hostname === "localhost") { //TODO remove condition when this tab is ready to be released
      tabs.push('availability_zones');
    }
    if (canAutoscale) {
      tabs.push('autoscaling');
    }

    let currentTab;
    switch (currentArea) {
      case 'availability_zones':
        currentTab = this.renderAvailabilityZoneTab();
        break;
      case 'autoscaling':
        currentTab = this.renderAutoscalingTab();
        break;
      default:
        currentTab = this.renderArea(currentArea);
        break;
    }

    return (
      <React.Fragment>
        <nav className='nav-with-buttons'>
          <ul className='nav nav-tabs'>
            { tabs.map(area => (
              <li key={area} role="presentation" className={currentArea == area ? "active" : ""}>
                <a href="#" onClick={(e) => { e.preventDefault(); this.changeArea(area); }}>
                  {t(area)}
                </a>
              </li>
            ))}
          </ul>
          {canEdit && scope.isProject() && this.props.metadata.bursting !== null && <div className='nav-main-buttons'>
            <Link to={`/settings`} className='btn btn-primary btn-sm'>Settings</Link>
          </div>}
        </nav>
        {currentTab}
      </React.Fragment>
    );
  }
}
