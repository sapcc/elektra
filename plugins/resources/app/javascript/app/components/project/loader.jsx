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
    props.loadProjectOnce(props.scopeData);
  }

  render() {
    if (this.props.receivedAt) {
      return this.props.children;
    }
    if (this.props.isFetching) {
      return <p><span className='spinner'/> Loading project...</p>;
    }
    return <p className='text-danger'>Failed to load project</p>;
  }

}
