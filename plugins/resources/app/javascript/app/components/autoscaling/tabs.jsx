import AutoscalingConfig from '../../containers/autoscaling/config';

const pages = [
  { label: "Configuration", component: AutoscalingConfig },
  // { label: "Pending operations", component: AutoscalingPendingOps },
  // { label: "Recently succeeded", component: AutoscalingSucceededOps },
  // { label: "Recently failed", component: AutoscalingFailedOps },
  // { label: "Scraping errors", component: AutoscalingScrapingErrors },
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
    const forwardProps = {
      scopeData: this.props.scopeData,
      canEdit: this.props.canEdit,
    };

    const CurrentComponent = pages[this.state.active].component;
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
          <CurrentComponent {...forwardProps} />
        </div>
      </div>
    );
  }
}
