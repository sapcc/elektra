import { Scope } from '../scope';

import ReloadIndicator from '../components/reload_indicator';

export default class Loader extends React.Component {
  componentWillReceiveProps(nextProps) {
    // load dependencies unless already loaded
    this.loadDependencies(nextProps)
  }

  componentDidMount() {
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  }

  loadDependencies = (props) => {
    props.loadDataOnce(props.scopeData);
    props.loadCapacityOnce(props.scopeData);
    if (props.hasCastellum) {
      props.discoverAutoscalableSubscopesOnce(props.scopeData);
    }
  }

  render() {
    if (this.props.receivedAt && !this.props.isIncomplete) {
      return <ReloadIndicator
        children={this.props.children}
        isReloading={this.props.isFetching} />;
    }
    const scope = new Scope(this.props.scopeData);
    const msg = this.props.isFetching
      ? <p><span className='spinner'/> Loading data for {scope.level()}...</p>
      : this.props.isIncomplete
        ? <p className='alert alert-danger'>Still working on initializing {scope.level()}. Please try again later.</p>
        : <p className='text-danger'>Failed to load data for {scope.level()}</p>;
    return this.props.isModal
      ? <div className='modal-body'>{msg}</div>
      : msg;
  }

}
