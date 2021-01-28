import AutoscalingConfig from '../../containers/autoscaling/config';
import AutoscalingConfigNg from '../../containers/autoscaling/config_ng';
import AutoscalingOpsReport from '../../containers/autoscaling/ops_report';

const pages = [
  { label: "Config by Project", component: AutoscalingConfigNg },
  { label: "Config by Resource", component: AutoscalingConfig },
  { label: "Pending operations", component: AutoscalingOpsReport, props: { reportType: 'pending' } },
  { label: "Recently succeeded", component: AutoscalingOpsReport, props: { reportType: 'recently-succeeded' } },
  { label: "Recently failed", component: AutoscalingOpsReport, props: { reportType: 'recently-failed' } },
];

export default class AutoscalingTabs extends React.Component {
  state = {
    active: 0,
  }



  handleSelect(pageIdx, e) {
    e.preventDefault();
    this.setState({
      ...this.state,
      active: pageIdx,
    });
  }

  render() {
    if(!this.props.canAutoscale) {
      return <><span className="spinner"/> Loading...</>
    }
    
    const CurrentPage = pages[this.state.active].component;
    const pageProps = {
      ...(pages[this.state.active].props || {}),
      scopeData: this.props.scopeData,
      canEdit: this.props.canEdit,
    };

    return (
      <div>
        <div className="col-sm-2">
          <ul className="nav nav-pills nav-stacked">
            { pages.map((conf, idx) => (
              <li key={idx} role="presentation" className={idx == this.state.active ? "active" : ""}>
                <a href="#" onClick={(e) => this.handleSelect(idx, e)}>{conf.label}</a>
              </li>
            ))}
          </ul>
        </div>
        <div className="col-sm-10">
          <CurrentPage key={this.state.active} {...pageProps} />
        </div>
      </div>
    );
  }
}
