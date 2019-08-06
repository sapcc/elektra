import moment from 'moment';
import { Link } from 'react-router-dom';

import { Scope } from '../scope';
import { byUIString, byNameIn, t } from '../utils';
import Category from '../containers/category';
import AutoscalingConfig from '../containers/autoscaling/config';
import ProjectSyncAction from '../components/project/sync_action';

export default class Overview extends React.Component {
  state = {
    currentArea: null,
  }

  changeArea = (area) => {
    this.setState({...this.state, currentArea: area});
  }

  renderNavbar(currentArea, canEdit, canAutoscale, scope) {
    const tabs = Object.keys(this.props.overview.areas).sort(byUIString);
    if (canAutoscale) {
      tabs.push('autoscaling');
    }
    return (
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
    );
  }

  renderCurrentArea() {
    const props = this.props;
    const scope = new Scope(props.scopeData);

    const { areas, categories, scrapedAt, minScrapedAt, maxScrapedAt } = props.overview;
    const currentArea = this.state.currentArea || Object.keys(areas).sort()[0];
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
        {this.renderNavbar(currentArea, props.canEdit, props.canAutoscale, scope)}
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

  renderAutoscalingTab() {
    const props = this.props;
    const scope = new Scope(props.scopeData);
    return (
      <React.Fragment>
        {this.renderNavbar('autoscaling', props.canEdit, props.canAutoscale, scope)}
        <AutoscalingConfig scopeData={props.scopeData} canEdit={props.canEdit} />
      </React.Fragment>
    );
  }

  render() {
    switch (this.state.currentArea) {
      case 'autoscaling':
        return this.renderAutoscalingTab();
      default:
        return this.renderCurrentArea();
    }
  }
}
