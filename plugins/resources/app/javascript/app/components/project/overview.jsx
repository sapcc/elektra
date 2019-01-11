import moment from 'moment';

import { byUIString, t } from '../../utils';
import ProjectService from '../../containers/project/service';

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

  renderNavbar(currentArea) {
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
      </nav>
    );
  }

  render() {
    if (!policy.isAllowed("project:show")) {
      return <p>You are not allowed to see this page</p>;
    }

    const props = this.props;
    if (props.isFetching) {
      return <p><span className='spinner'/> Loading project...</p>;
    }

    const currentArea = this.state.currentArea || Object.keys(props.overview.areas).sort()[0];
    const currentServices = props.overview.areas[currentArea];

    const minScrapedStr = moment.unix(props.overview.minScrapedAt).fromNow(true);
    const maxScrapedStr = moment.unix(props.overview.maxScrapedAt).fromNow(true);
    const ageDisplay = minScrapedStr == maxScrapedStr ? minScrapedStr : `between ${minScrapedStr} and ${maxScrapedStr}`;

    // TODO: overview page with critical resources?
    // TODO: Settings dialog for enabling/disabling bursting
    // TODO: info message: bursting is active/enabled/disabled
    // TODO: button: Request Quota Package
    // TODO: button: Sync Now

    return (
      <React.Fragment>
        {this.renderNavbar(currentArea)}
        {currentServices.sort(byUIString).map(serviceType => (
          <ProjectService key={serviceType} serviceType={serviceType} flavorData={this.props.flavorData} />
        ))}
        <div className='row'>
          <div className='col-md-6 col-md-offset-2'>
            Usage data last updated {ageDisplay} ago
          </div>
        </div>
      </React.Fragment>
    );
  }
}
