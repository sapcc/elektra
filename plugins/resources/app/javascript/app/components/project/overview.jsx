import { STRINGS } from '../../constants';

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

  // TODO make this its own component
  renderNavbar(currentArea) {
    return (
      <nav className='nav-with-buttons'>
        <ul className='nav nav-tabs'>
          { Object.keys(this.props.overview.areas).sort().map((area, idx) => (
            <li key={area} role="presentation" className={currentArea == area ? "active" : ""}>
              <a href="#" onClick={(e) => { e.preventDefault(); this.changeArea(area); }}>
                {STRINGS[area]}
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
    console.log("Props for ProjectOverview");
    console.log(this.props);

    const currentArea = this.state.currentArea || Object.keys(props.overview.areas).sort()[0];

    // TODO: overview page with critical resources?
    // TODO: Settings dialog for enabling/disabling bursting
    // TODO: button: Request Quota Package

    return (
      <React.Fragment>
        {this.renderNavbar(currentArea)}
        <p>This is my state:</p>
        <pre>{JSON.stringify(this.state, null, 2)}</pre>
        <p>These are my props:</p>
        <pre>{JSON.stringify(this.props, null, 2)}</pre>
      </React.Fragment>
    );
  }
}
