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
  }

  render() {
    if (this.props.receivedAt) {
      return <ReloadIndicator
        children={this.props.children}
        isReloading={this.props.isFetching} />;
    }
    const scope = new Scope(this.props.scopeData);
    if (this.props.isFetching) {
      return <p><span className='spinner'/> Loading data for {scope.level()}...</p>;
    }
    return <p className='text-danger'>Failed to load data for {scope.level()}</p>;
  }

}
