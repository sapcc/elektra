//TODO remove
const mockComponent = (text) => (props) => <p>{text}</p>;

const pages = [
  { label: "Configuration", component: mockComponent("Hello config") },
  { label: "Recently succeeded", component: mockComponent("Hello recently succeeded") },
  { label: "Recently failed", component: mockComponent("Hello recently failed") },
  { label: "Scraping errors", component: mockComponent("Hello scraping errors") },
];

export default class CastellumTabs extends React.Component {
  state = {
    active: 0,
  }

  componentDidMount() {
    this.props.loadResourceConfigOnce(this.props.projectId);
  }

  handleSelect(pageIdx, e) {
    e.preventDefault();
    this.setState({
      ...this.state,
      active: pageIdx,
    });
  }

  render() {
    const { errorMessage, isFetching } = this.props.resourceConfig;
    if (isFetching) {
      return <p><span className='spinner' /> Loading...</p>;
    }
    if (errorMessage) {
      return <p className='alert alert-danger'>Cannot load autoscaling configuration: {errorMessage}</p>;
    }
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
          <CurrentComponent />
          <pre>{JSON.stringify(this.props.resourceConfig, null, 2)}</pre>
        </div>
      </div>
    );
  }
}
