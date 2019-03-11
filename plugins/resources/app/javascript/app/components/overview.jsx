import moment from 'moment';
import { Link } from 'react-router-dom';

import { Scope } from '../scope';
import { byUIString, t } from '../utils';
import Category from '../containers/category';
import ProjectSyncAction from '../components/project/sync_action';

export default class Overview extends React.Component {
  state = {
    currentArea: null,
  }

  changeArea = (area) => {
    this.setState({...this.state, currentArea: area});
  }

  renderNavbar(currentArea, canEdit, scope) {
    return (
      <nav className='nav-with-buttons'>
        <ul className='nav nav-tabs'>
          { Object.keys(this.props.overview.areas).sort(byUIString).map(area => (
            <li key={area} role="presentation" className={currentArea == area ? "active" : ""}>
              <a href="#" onClick={(e) => { e.preventDefault(); this.changeArea(area); }}>
                {t(area)}
              </a>
            </li>
          ))}
        </ul>
        {canEdit && scope.isCluster() && this.props.metadata.bursting !== null && <div className='nav-main-buttons'>
          <Link to={`/settings`} className='btn btn-primary btn-sm'>Settings</Link>
        </div>}
      </nav>
    );
  }

  render() {
    const props = this.props;
    const scope = new Scope(props.scopeData);

    const { areas, categories, scrapedAt } = props.overview;
    const currentArea = this.state.currentArea || Object.keys(areas).sort()[0];
    const currentServices = areas[currentArea];

    const currScrapedAt = currentServices.map(serviceType => scrapedAt[serviceType]);
    const minScrapedStr = moment.unix(Math.min(...currScrapedAt)).fromNow(true);
    const maxScrapedStr = moment.unix(Math.max(...currScrapedAt)).fromNow(true);
    const ageDisplay = minScrapedStr == maxScrapedStr ? minScrapedStr : `between ${minScrapedStr} and ${maxScrapedStr}`;

    //sorting predicate for categories: sort by translated name, but categories
    //named after their service come first
    const byNameIn = serviceType => (a, b) => {
      if (t(serviceType) == t(a)) { return -1; }
      if (t(serviceType) == t(b)) { return +1; }
      return byUIString(a, b);
    };

    const syncActionProps = {
      scopeData: props.scopeData,
      syncStatus: props.syncStatus,
      syncProject: props.syncProject,
      pollRunningSyncProject: props.pollRunningSyncProject,
    };

    // TODO: button: Request Quota Package
    return (
      <React.Fragment>
        {this.renderNavbar(currentArea, props.canEdit, scope)}
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
}
