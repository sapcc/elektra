import NivoBarChart from './nivoBarChart'
import Details from './details'

class App extends React.Component {

  state = {
    hover: "none",
    clickBarData: null,
    clickedBar: "none",
    filter: '',
    showDetails: false,
    clickService: "all"
  };

  componentDidMount() {
    this.props.fetchCostReport()
  }

  onHoverRect = (d) => {
    this.setState({ hover: d.data.id })
  }

  onClickBarChart = (data) => {
    if (this.state.clickedBar == data.date) {
      this.setState({showDetails: false, clickedBar: "none"})
    } else {
      this.setState({clickBarData: data, showDetails: true, clickedBar: data.date})
    }
  }

  onClickLegendRect = (service) => {
    this.setState({clickService: service})
  }

  onCloseDetails = () => {
    this.setState({showDetails: false, clickedBar: "none"})
  }

  render() {
    const colors = ["#008fd3", "#be008c", "#fa9100", "#93c939", "#ccc"]
    return (
      <React.Fragment>
        <div className="bs-callout bs-callout-info bs-callout-emphasize">
          <p>Cost report for the last 12 months.</p>
          <ul>
            <li>Click on the columns to show a detailed view for the services.</li>
            <li>Click on the legend to choose a service.</li>
          </ul>
        </div>

        {this.props.cost.error &&
          <React.Fragment>
            <span className="text-danger">
              {this.props.cost.error.error}
            </span>
          </React.Fragment>
        }

        <NivoBarChart cost={this.props.cost} colors={colors} onClick={this.onClickBarChart} clickedBar={this.state.clickedBar} onClickLegend={this.onClickLegendRect} clickService={this.state.clickService}/>

        <div className="cost-details">
          <Details data={this.state.clickBarData} colors={colors} services={this.props.cost.services} serviceMap={this.props.cost.serviceMap} onClose={this.onCloseDetails} showDetails={this.state.showDetails} clickService={this.state.clickService}/>
        </div>
      </React.Fragment>
    )
  }
}

export default App;
