export default class ProjectLoader extends React.Component {
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
    if (!policy.isAllowed('project:show')) {
      return <p>You are not allowed to see this page</p>;
    }
    if (this.props.isFetching) {
      return <p><span className='spinner'/> Loading project...</p>;
    }
    if (!this.props.receivedAt) {
      return <p className='text-danger'>Failed to load project</p>;
    }

    return this.props.children;
  }

}
