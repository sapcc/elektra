import moment from 'moment';
import { Link } from 'react-router-dom';

import { byUIString, t } from '../../utils';
import ProjectCategory from '../../containers/project/category';
import ProjectSyncAction from '../../components/project/sync_action';

export default class ProjectOverview extends React.Component {
  state = {
    currentArea: null,
  }

  componentWillReceiveProps(nextProps) {
    // load dependencies unless already loaded
    this.loadDependencies(nextProps)
  }

  componentDidMount() {
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  }

  loadDependencies = (props) => {
    props.loadProjectOnce({
      domainID: props.domainID,
      projectID: props.projectID,
    })
  }

  changeArea = (area) => {
    this.setState({...this.state, currentArea: area});
  }

  renderNavbar(currentArea, canEdit) {
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
        {canEdit && this.props.metadata.bursting !== null && <div className='nav-main-buttons'>
          <Link to={`/settings`} className='btn btn-primary btn-sm'>Settings</Link>
        </div>}
      </nav>
    );
  }

  render() {
    if (!policy.isAllowed('project:show')) {
      return <p>You are not allowed to see this page</p>;
    }
    const canEdit = policy.isAllowed('project:edit');

    const props = this.props;
    if (props.isFetching) {
      return <p><span className='spinner'/> Loading project...</p>;
    }
    if (!props.overview) {
      return <p className='text-danger'>Failed to load project</p>;
    }

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

    // TODO: overview page with critical resources?
    // TODO: button: Request Quota Package

    const syncActionProps = {
      domainID: props.domainID,
      projectID: props.projectID,
      syncStatus: props.syncStatus,
      syncProject: props.syncProject,
      pollRunningSyncProject: props.pollRunningSyncProject,
    };

    return (
      <React.Fragment>
        {this.renderNavbar(currentArea, canEdit)}
        {currentServices.sort(byUIString).map(serviceType => (
          <React.Fragment key={serviceType}>
            {categories[serviceType].sort(byNameIn(serviceType)).map(categoryName => (
              <ProjectCategory key={categoryName} categoryName={categoryName} flavorData={this.props.flavorData} />
            ))}
          </React.Fragment>
        ))}
        <div className='row'>
          <div className='col-md-6 col-md-offset-2'>
            Usage data last updated {ageDisplay} ago{' '}
            {canEdit && <ProjectSyncAction {...syncActionProps} />}
          </div>
        </div>
      </React.Fragment>
    );
  }
}
