export default class ProjectOverview extends React.Component {
  state = {}

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

  render() {
    if (!policy.isAllowed("project:show")) {
      return <span>You are not allowed to see this page</span>;
    }

    // console.log("Props for ProjectOverview");
    // console.log(this.props);
    return (
      <React.Fragment>
        <p>These are my props:</p>
        <pre>{JSON.stringify(this.props, null, 2)}</pre>
      </React.Fragment>
    );
  }
}
